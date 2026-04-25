// Copyright 2010-2025 Google LLC
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Classic diet problem solved with MathOpt and the HiGHS LP solver.
//
// Pick non-negative servings of each food to:
//   1. maximize total protein,
//   2. then, among protein-optimal diets, minimize total cost,
// while meeting per-nutrient lower and upper bounds.
//
//   lexicographic:
//      max   sum_f protein[f] * x[f]
//      min   sum_f cost[f] * x[f]
//   s.t.  nmin[n] <= sum_f amount[f][n] * x[f] <= nmax[n]   for each nutrient n
//         x[f] >= 0                                         for each food f

#include <iostream>
#include <limits>
#include <ostream>
#include <string>
#include <vector>

#include "absl/status/status.h"
#include "ortools/base/init_google.h"
#include "ortools/base/logging.h"
#include "ortools/base/status_macros.h"
#include "ortools/math_opt/cpp/math_opt.h"

namespace {

namespace math_opt = ::operations_research::math_opt;

struct Food {
  std::string name;
  double cost;
  // Amount of each nutrient per serving, ordered to match the nutrient table.
  std::vector<double> nutrients;
};

struct Nutrient {
  std::string name;
  double min;
  double max;
};

absl::Status Main() {
  // Nutrients: calories (kcal), protein (g), fat (g), carbohydrates (g).
  const std::vector<Nutrient> nutrients = {
      {"calories", 2000, 2500},
      {"protein", 50, 150},
      {"fat", 40, 80},
      {"carbs", 200, 350},
  };

  // Per-serving cost (USD) and nutrient content for each food.
  const std::vector<Food> foods = {
      {"bread", 0.80, {165, 9, 3, 49}},
      {"milk", 0.80, {150, 8, 8, 12}},
      {"cheese", 2.00, {400, 25, 33, 1}},
      {"potato", 0.50, {160, 4, 0, 37}},
      {"fish", 3.50, {200, 22, 12, 0}},
      {"yogurt", 1.20, {110, 10, 2, 17}},
  };

  math_opt::Model model("diet");

  // One non-negative continuous variable per food (number of servings).
  std::vector<math_opt::Variable> servings;
  servings.reserve(foods.size());
  for (const Food& food : foods) {
    servings.push_back(model.AddContinuousVariable(
        0.0, std::numeric_limits<double>::infinity(), food.name));
  }

  // Nutrient range constraints.
  for (int n = 0; n < nutrients.size(); ++n) {
    math_opt::LinearExpression intake;
    for (int f = 0; f < foods.size(); ++f) {
      intake += foods[f].nutrients[n] * servings[f];
    }
    model.AddLinearConstraint(intake >= nutrients[n].min,
                              nutrients[n].name + "_min");
    model.AddLinearConstraint(intake <= nutrients[n].max,
                              nutrients[n].name + "_max");
  }

  // Primary objective: maximize total protein.
  math_opt::LinearExpression total_protein;
  for (int f = 0; f < foods.size(); ++f) {
    total_protein += foods[f].nutrients[1] * servings[f];
  }
  model.Maximize(total_protein);
  //const math_opt::Objective max_protein = model.AddMaximizationObjective(total_protein, 0, "protein");

  // Secondary objective: among protein-optimal diets, minimize total cost.
  math_opt::LinearExpression total_cost;
  for (int f = 0; f < foods.size(); ++f) {
    total_cost += foods[f].cost * servings[f];
  }
  const math_opt::Objective min_cost =
      model.AddMinimizationObjective(total_cost, /*priority=*/1, "cost");

  ASSIGN_OR_RETURN(const math_opt::SolveResult result,
                   Solve(model, math_opt::SolverType::kHighs));
  RETURN_IF_ERROR(result.termination.EnsureIsOptimalOrFeasible());

  std::cout << "Maximum daily protein: " << result.objective_value()
            << std::endl;
  std::cout << "Minimum daily cost at max protein: "
            << result.objective_value(min_cost) << std::endl;
  std::cout << "Servings:" << std::endl;
  for (int f = 0; f < foods.size(); ++f) {
    std::cout << "  " << foods[f].name << ": "
              << result.variable_values().at(servings[f]) << std::endl;
  }
  return absl::OkStatus();
}

}  // namespace

int main(int argc, char** argv) {
  InitGoogle(argv[0], &argc, &argv, true);
  const absl::Status status = Main();
  if (!status.ok()) {
    LOG(QFATAL) << status;
  }
  return 0;
}
