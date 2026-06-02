# InVivoTools Manual

InVivoTools is a system for journaling, analyzing, and retrieving experimental
data. The `graph_db` database provides a flexible way to produce figures from
stored data.

## Getting started

- [Installation and update](1.2-Installation-and-update.md)
  - [Installing Git software](1.2-Installation-and-update.md#installation-git-software)
  - [Installing InVivoTools](1.2-Installation-and-update.md#installing-invivotools)
  - [Post installation](1.2-Installation-and-update.md#post-installation)
  - [Updating from the repository](1.2-Installation-and-update.md#updating-from-repository)
  - [Committing local changes](1.2-Installation-and-update.md#committing-local-changes)

## Working with databases

- [Database-control GUI](2.2-Database-control.md)
  - [Access to databases](2.2-Database-control.md#access-to-databases)
- [Subject databases](2.4-Subject-databases.md)
  - [Mice: `mouse_db`](2.4-Subject-databases.md#mice---mouse_db)
  - [Protocols: `dec_db`](2.4-Subject-databases.md#protocols---dec_db)
- [Experiment databases](2.5-Experiment-databases.md)
  - [Analysis parameters](2.5-Experiment-databases.md#analysis-parameters)
  - [Optical imaging: `experiment_db`](2.5-Experiment-databases.md#optical-imaging---experiment_db)
  - [Electrophysiology: `ectestdb`](2.5-Experiment-databases.md#electrophysiology---ectestdb)
  - [Two-photon imaging: `tptestdb`](2.5-Experiment-databases.md#two-photon-imaging---tptestdb)

## Making figures

- [Making figures](3.1-Making-figures.md)
  - [Group database: `group_db`](3.1-Making-figures.md#group-database---group_db)
  - [Measure database: `measure_db`](3.1-Making-figures.md#measure-database---measure_db)
- [Example figures](3.2-Example-figures.md)
  - [Simple examples](3.2-Example-figures.md#simple-examples)
  - [Puncta gained and lost time series](3.2-Example-figures.md#example-puncta-gained-and-lost-time-series)
- [`graph_db` fields](3.3-Graph_db-fields.md)

## Reference

- [Software folder structure](9.1-Software-folder-structure.md)
- [Database functions](9.2-Database-functions.md)
  - [Generic database functions](9.2-Database-functions.md#generic-database-functions)
  - [Database administration](9.2-Database-functions.md#database-administration)
- [Analysis functions](9.3-Analysis-functions.md)
- [Results functions](9.4-Results-functions.md)
- [Graph functions](9.5-Graph-functions.md)

## Related documentation

- [NewStim3 manual](https://github.com/heimel/NewStim3/blob/master/docs/README.md)
- [Puncta analysis using MATLAB](https://sites.google.com/site/alexanderheimel/protocols/puncta-analysis-using-matlab)

Maintainer: Alexander Heimel

*Please edit and improve if you can.*
