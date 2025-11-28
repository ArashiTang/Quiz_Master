# Quiz Master Development Log

## 0.1 (2025-09-01)

- Added: Streamlined the startup process and established a minimum runnable architecture for the quiz/onlinetest module, adding basic interfaces and routes.
- Fixed: Resolved compilation failures caused by incorrect resource imports, and corrected null pointer exceptions during Online Test initialization.

- ## 0.2 (2025-09-08)

- Added: Completed the initial experimental version of the local database table structure, clarifying the relationships between entities such as quiz, options, answers, and practice results, laying the foundation for subsequent data modeling.
- Fixed: Optimized route navigation and state recycling in the Demo, avoiding data reload issues when repeatedly entering the page.

- ## 0.3 (2025-09-15)

- Added: Refined the table structure based on the design of multiple quizzes, multiple questions, and multiple options; added quiz-record and question-record to support recorded test results.
- Fixed: Unified ID/UUID generation and storage strategy to avoid missing cross-table joins during statistics.


- ## 0.4 (2025-09-22)

- Added: Added serialization and deserialization tools to the local table structure, supporting local demos to run directly with offline data; supplemented the prototype of a batch import script for questions, options, and answers.
- Fixed: Handled field default values ​​and null value constraints to reduce crashes during local writes.


- ## 0.5 (2025-09-29)

- Added: Designed a mapping scheme between the cloud (Supabase) and local tables, clearly defining core tables such as quiz, question, option, answer, and practice_result, and planned field alignment strategies.
- Fixed: Adjusted local/cloud timestamp format to avoid parsing errors during cross-platform synchronization.

- ## 0.6 (2025-10-10)

- Added: Created the initial schema and permission policy in Supabase, wrote migration scripts and data seeding scripts, and completed the basic table creation for quiz-question-option-answer-practice_result.
- Fixed: Resolved the slow query issue caused by missing indexes in the cloud table, and added necessary unique keys and composite indexes.

- ## 0.7 (2025-10-20)

- Added: Implemented configuration encapsulation for Supabase on the Flutter side, completed session management and basic CRUD operations, and integrated with cloud quiz and question list reading.
- Fixed: Corrected the retry logic under mobile network fluctuations to reduce duplicate requests caused by timeouts.

- ## 0.8 (2025-11-05)

- Added: Introduced the workflow framework for Online Test, including question extraction, timing, answer progress recording, answer reporting, and score calculation; added a view for reviewing incorrect questions.
- Fixed: Fixed issues with question order disorder and timer reset in Online Test, ensuring consistency between practice results and cloud data.

## 0.9 (2025-11-15)

- Added: Improved the score report, providing question-level feedback, accuracy statistics, and practice record queries; introduced environment configuration instructions, supporting one-click initialization of the Supabase connection.
- Fixed: Fixed character encoding issues during report export and optimized the conflict merging strategy during local/cloud data synchronization.

## 1.0 (2025-11-27)

- Added: Performed end-to-end self-testing of the entire quiz and online practice process, supplemented documentation and example configurations, and released a stable version.
- Fix: Resolved legacy differences in routing, permissions, and statistical methods to ensure Quiz Master runs smoothly both locally and in the cloud.
