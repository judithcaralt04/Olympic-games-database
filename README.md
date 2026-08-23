# Olympic Games Database

An Oracle SQL database designed and implemented from a real world Olympic Games 2024 dataset. Built for the Database Design course as a three person team project.

This repository is private. It is shared for portfolio purposes only, and access is limited to people who have been explicitly invited.

## What it covers

- A conceptual entity relationship model and a relational model for a dataset covering athletes, teams, coaches, sports, disciplines, events, sessions, medals, venues, seating zones and ticket sales
- A physical model implemented in Oracle SQL, with data types chosen for efficiency and consistency with the source data
- Import and transformation of the original CSV files into the physical model, using temporary staging tables and INSERT-SELECT scripts to clean up inconsistencies and enforce the relations and constraints
- 20 SQL queries that answer real analytical questions about the dataset, such as which athletes won the most medals, which teams won at least one gold medal, or which venues hosted the most different events, each one paired with a validation check
- A set of triggers to automate and control specific operations on the database

## Tech stack

- Oracle SQL
- CSV as the source data format

## My contribution

This was a three person team project. My part covered most of the INSERT-SELECT import scripts that moved and cleaned the data from the staging tables into the final physical model, several of the analytical queries involving joins across multiple tables, and several of the triggers.

## Contents

- `scripts/G6_modelfisic.sql`: creates all the tables of the physical model
- `scripts/G6_importacio.sql`: imports the CSV files into staging tables and transforms them into the final model
- `scripts/G6_consultes.sql`: the 20 analytical queries, their validation checks, and the triggers
- `data/`: the two source CSV files referenced above, `tickets.csv` and `seating_zones.csv`
- `models/`: the conceptual and relational model diagrams
- `docs/report.pdf`: the full project report, covering the model justification, data type choices, data import process and query explanations
