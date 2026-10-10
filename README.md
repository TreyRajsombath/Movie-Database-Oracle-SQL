# Movie Database (Oracle SQL)

A relational movie database built for CSCI 3360 (Database Systems), Spring 2026.
The project takes a database from ER/EER design through a relational schema,
Oracle DDL, data loading, and analytical queries.

## What's inside
- 9 tables: Person, Movie, Ratings, Production_Release, Production_Requirements,
  Department, Production_Crew, Director, Actor
- Primary keys, foreign keys, UNIQUE, NOT NULL, and CHECK constraints
- 10 movies and 60 people loaded with INSERT statements
- 10 queries: single-table filter, two-, three- and four-table joins,
  UNION and MINUS set operations, and GROUP BY aggregates

## Running it
Run `CSCI-3360_Final-Project_Group-11.sql` in Oracle SQL*Plus. It drops and
recreates all tables, loads the data, and runs the queries.
