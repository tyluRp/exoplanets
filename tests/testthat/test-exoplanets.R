options(
  exoplanets.progress = FALSE,
  exoplanets.quiet = TRUE
)

test_that("exoplanets is memoised", {
  expect_true(memoise::is.memoised(exoplanets))
})

test_that("parse_url works", {
  # test errors when required parameters aren't given
  expect_snapshot_error(parse_url())
  expect_snapshot_error(parse_url("ps"))
  expect_snapshot_error(parse_url("ps", "*"))

  # test errors when incorrect format given
  expect_snapshot_error(parse_url("ps", "*", format = "sqlite"))

  # test csv url parsing & limit = 10
  x <- parse_url("ps", "*", 10, "csv")
  expect_equal(x$table, "ps")
  expect_equal(x$columns, "*")
  expect_equal(x$limit, 10)
  expect_equal(x$format, "csv")
  expect_equal(x$type, "text/csv")
  expect_equal(x$query, "select+*+from+ps+top+10&format=csv")
  expect_equal(x$url, "https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+*+from+ps+top+10&format=csv")

  # test json url parsing & limit = 10
  x <- parse_url("k2names", c("epic_id", "k2_name"), 10, "json")
  expect_equal(x$table, "k2names")
  expect_equal(x$columns, "epic_id,k2_name")
  expect_equal(x$limit, 10)
  expect_equal(x$format, "json")
  expect_equal(x$type, "application/json")
  expect_equal(x$query, "select+epic_id,k2_name+from+k2names+top+10&format=json")
  expect_equal(x$url, "https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+epic_id,k2_name+from+k2names+top+10&format=json")

  # test tsv url parsing & limit = NULL
  x <- parse_url("k2names", c("epic_id", "k2_name"), NULL, "tsv")
  expect_equal(x$table, "k2names")
  expect_equal(x$columns, "epic_id,k2_name")
  expect_equal(x$limit, NULL)
  expect_equal(x$format, "tsv")
  expect_equal(x$type, "text/tab-separated-values")
  expect_equal(x$query, "select+epic_id,k2_name+from+k2names&format=tsv")
  expect_equal(x$url, "https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+epic_id,k2_name+from+k2names&format=tsv")
})

with_mock_dir("exoplanets-default", {
  test_that("exoplanets default works", {
    expect_s3_class(exoplanets("k2names"), "data.frame")
  })
})

with_mock_dir("exoplanets-csv", {
  test_that("exoplanets csv works", {
    expect_s3_class(exoplanets("k2names", format = "csv"), "data.frame")
  })
})

with_mock_dir("exoplanets-tsv", {
  test_that("exoplanets tsv works", {
    expect_s3_class(exoplanets("k2names", format = "tsv"), "data.frame")
  })
})

with_mock_dir("exoplanets-json", {
  test_that("exoplanets json works", {
    expect_true(inherits(exoplanets("k2names", format = "json"), "list"))
  })
})

with_mock_dir("exoplanets-default-select", {
  test_that("exoplanets default works when selecting", {
    r <- exoplanets("k2names", c("epic_id", "k2_name"))
    expect_s3_class(r, "data.frame")
    expect_true(all(c("epic_id", "k2_name") %in% names(r)))
  })
})

with_mock_dir("exoplanets-csv-select", {
  test_that("exoplanets csv works when selecting", {
    r <- exoplanets("k2names", c("epic_id", "k2_name"), format = "csv")
    expect_s3_class(r, "data.frame")
    expect_true(all(c("epic_id", "k2_name") %in% names(r)))
  })
})

with_mock_dir("exoplanets-tsv-select", {
  test_that("exoplanets tsv works when selecting", {
    r <- exoplanets("k2names", c("epic_id", "k2_name"), format = "tsv")
    expect_s3_class(r, "data.frame")
    expect_true(all(c("epic_id", "k2_name") %in% names(r)))
  })
})

with_mock_dir("exoplanets-json-select", {
  test_that("exoplanets json works when selecting", {
    r <- exoplanets("k2names", c("epic_id", "k2_name"), format = "json")
    expect_true(inherits(r, "list"))
    expect_true(all(c("epic_id", "k2_name") %in% unique(unlist(lapply(r, names)))))
  })
})

with_mock_dir("exoplanets-table-ps", {
  test_that("ps table works", {
    column <- "pl_name"
    expect_s3_class(exoplanets("ps", column), "data.frame")
  })
})

with_mock_dir("exoplanets-table-pscomppars", {
  test_that("pscomppars table works", {
    column <- "pl_name"
    expect_s3_class(exoplanets("pscomppars", column), "data.frame")
  })
})

with_mock_dir("exoplanets-table-keplernames", {
  test_that("keplernames table works", {
    column <- "pl_name"
    expect_s3_class(exoplanets("keplernames", column), "data.frame")
  })
})

with_mock_dir("exoplanets-table-k2names", {
  test_that("k2names table works", {
    column <- "pl_name"
    expect_s3_class(exoplanets("k2names", column), "data.frame")
  })
})

with_mock_dir("exoplanets-table-emissionspec", {
  test_that("emissionspec table works", {
    column <- "centralwavelng"
    expect_s3_class(exoplanets("emissionspec", column), "data.frame")
  })
})

with_mock_dir("exoplanets-table-transitspec", {
  test_that("transitspec table works", {
    column <- "centralwavelng"
    expect_s3_class(exoplanets("transitspec", column), "data.frame")
  })
})

with_mock_dir("exoplanets-example-1", {
  test_that("example 1 works", {
    r <- exoplanets("ps", c("pl_name", "discoverymethod"))
    expect_s3_class(r, "data.frame")
    expect_true(all(c("pl_name", "discoverymethod") %in% names(r)))
  })
})

with_mock_dir("exoplanets-example-2", {
  test_that("example 2 works", {
    r <- exoplanets("ps", c("pl_name", "discoverymethod"), format = "json")
    expect_true(inherits(r, "list"))
    expect_true(all(c("pl_name", "discoverymethod") %in% names(r[[1]])))
  })
})

with_mock_dir("exoplanets-example-3", {
  test_that("example 3 works", {
    r <- exoplanets("k2names")
    expect_s3_class(r, "data.frame")
  })
})

with_mock_dir("exoplanets-quiet-option", {
  test_that("quiet option works", {
    expect_output(exoplanets("k2names"), NA)
  })
})

with_mock_dir("exoplanets-limit", {
  test_that("limit parameter works", {
    r <- exoplanets("keplernames", limit = 5)
    expect_equal(nrow(r), 5)
  })
})
