"""
Concrete data service.

This Django app manages API endpoints related to managing "concrete data", or
data that serves as the foundational sources of truth for users. This is opposed
to "derived data", which is data computed via mathematical, logical /
relational, or other types of transformations. For example, a materialized view
would be considered "derived data", while a CSV upload would be considered
"concrete data".

Making this distinction helps ensure application data flow is unitary, and that
consequently, underlying data pipelines are acyclic. This methodology may reduce
likelihood of data corruption via concurrency / paralellism or other concerns,
and helps describe the data model more clearly.
"""
