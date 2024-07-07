/* Replace #Missing with 0 */
WITH RawData AS(
  WITH fixed AS (
    SELECT Cabinet, Dept, Program, Expense_Category, 
      REPLACE(FY21_Actual_Expense, '#Missing', '0') as FY21_Actual_Expense,
      REPLACE(FY22_Actual_Expense, '#Missing', '0') as FY22_Actual_Expense,
      REPLACE(FY23_Appropriation, '#Missing', '0') as FY23_Appropriation,
      REPLACE(FY24_Adopted, '#Missing', '0') as FY24_Adopted
    FROM `ced_budget_analysis.fy24-adopted-operating-budget`
  )
  SELECT
    Cabinet, Dept, Program, Expense_Category,
    SAFE_CAST(FY21_Actual_Expense as FLOAT64) as FY21_Spending,
    SAFE_CAST(FY22_Actual_Expense as FLOAT64) as FY22_Spending,
    SAFE_CAST(FY23_Appropriation as FLOAT64) as FY23_Budget,
    SAFE_CAST(FY24_Adopted as FLOAT64) as FY24_Budget
  From fixed
),
UnpivotedData AS (
SELECT 
  Cabinet, Dept, Program, Expense_Category, Year, Type, Amount
FROM RawData,
  UNNEST([
    STRUCT('2021' as Year, 'Spending' as Type, FY21_Spending as Amount),
    STRUCT('2022' as Year, 'Spending' as Type, FY22_Spending as Amount),
    STRUCT('2023' as Year, 'Budget' as Type, FY23_Budget as Amount),
    STRUCT('2024' as Year, 'Budget' as Type, FY24_Budget as Amount)
  ]) AS unpivot
)
SELECT * FROM UnpivotedData
