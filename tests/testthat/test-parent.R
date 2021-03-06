#! This file was automatically produced by the testextra package.
#! Changes will be overwritten.

context('tests extracted from file `parent.R`')
#line 34 "C:/rdtf/parsetools/R/parent.R"
test_that('parent', {#! @testing
    pd <- get_parse_data(parse(text='rnorm(10, mean=0, sd=1)', keep.source=TRUE))
    expect_identical(pd_get_parent_id(1, pd), 3L)
    expect_is(pd_get_parent_id(1, pd), "integer")

    expect_is(pd_get_parent_id(10000, pd), "integer", info="missing parent")
    expect_identical(pd_get_parent_id(10000, pd), NA_integer_, info="missing parent")

    expect_identical(pd_get_parent_id(pd$id, pd), pd$parent)
    expect_identical(pd_get_parent_id(0L, pd), NA_integer_)
})
#line 86 "C:/rdtf/parsetools/R/parent.R"
test_that('ancestors', {#! @testing
    pd <- get_parse_data(parse(text='rnorm(10, mean=0, sd=1)', keep.source=TRUE))
    id <- pd$id[pd$text=='rnorm']  #< Text ID
    sym <- parent(id)              #< Call identifier ID
    exp <- parent(sym)         #< Root expression id

    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations=Inf, aggregate=TRUE , include.self=TRUE , only.present = FALSE), c(id, sym, exp,0L), info = "defaults, but fully specified.")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations=Inf, aggregate=TRUE , include.self=FALSE, only.present = FALSE), c(    sym, exp,0L), info = "include.self=FALSE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations= 2 , aggregate=TRUE , include.self=FALSE, only.present = FALSE), c(    sym, exp   ), info = "ngenerations=2, include.self=FALSE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations= 2 , aggregate=TRUE , include.self=TRUE , only.present = FALSE), c(id, sym, exp   ), info = "ngenerations=2, include.self=TRUE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations= 2 , aggregate=FALSE, include.self=FALSE, only.present = FALSE),            exp    , info = "ngenerations= 2, aggregate=FALSE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations= 0 , aggregate=FALSE, include.self=TRUE , only.present = FALSE),   id              , info = "ngenerations=0, include.self=TRUE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations= 0 , aggregate=TRUE , include.self=TRUE , only.present = FALSE),   id              , info = "ngenerations=0, include.self=TRUE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations=Inf, aggregate=FALSE, include.self=FALSE, only.present = FALSE),                0L , info = "ngenerations= 2, aggregate=FALSE")
    expect_identical(pd_get_ancestor_ids( id, pd, ngenerations=Inf, aggregate=FALSE, include.self=FALSE, only.present = TRUE ),            exp    , info = "ngenerations= 2, aggregate=FALSE")

    expect_identical(pd_get_ancestor_ids(exp, pd, ngenerations=Inf, aggregate=FALSE, include.self=FALSE, only.present = TRUE ),            exp    , info = "ngenerations= 2, aggregate=FALSE")
    expect_identical(pd_get_ancestor_ids(exp, pd, ngenerations=Inf, aggregate=TRUE , include.self=FALSE, only.present = TRUE ), integer(0)        , info = "ngenerations= 2, aggregate=FALSE")

    expect_error(pd_get_ancestor_ids(id, pd, ngenerations=  0, include.self=FALSE))
    expect_error(pd_get_ancestor_ids(id, pd, ngenerations= -1))

    expect_error( pd_get_ancestor_ids(1:2, pd)
                , "length\\(id\\) == 1L is not TRUE"
                )
})
#line 112 "C:/rdtf/parsetools/R/parent.R"
test_that('last parameter', {#! @testing last parameter
pd <- get_parse_data(parse(text = '
function(){
setClass( "testClass"
     , slots = c( x="numeric" #< the x field
                , y="matrix"  #< the y field
                )
     )
 }', keep.source=TRUE))

    root.id <- roots(pd)
    body.id <- parent(.find_text('{'))
    id <- .find_text("#< the x field")

    expect_true(root.id %in% pd_get_ancestor_ids(id, pd))
    expect_false(root.id %in% pd_get_ancestor_ids(id, pd, last=body.id))

    id2 <- pd[pd$text=="#< the y field", 'id']

    expect_error(pd_get_ancestor_ids(c(id, id2), pd, last = body.id, include.self =FALSE))
    expect_identical( pd_get_ancestor_ids(id , pd, last = body.id, include.self =FALSE)
                    ,     ancestors   (id2, pd, last = body.id, include.self =FALSE)
                    )
    test.object <- pd_get_ancestor_ids(id, pd, last = body.id, include.self =FALSE)
    expect_false(root.id %in% test.object)
})
