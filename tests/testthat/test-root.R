#! This file was automatically produced by the testextra package.
#! Changes will be overwritten.

context('tests extracted from file `root.R`')
#line 71 "R/root.R"
test_that('is_root', {#@testing
    pd <- get_parse_data(parse(text='rnorm(10, mean=0, sd=1)', keep.source=TRUE))
    expect_true (pd_is_root(23, pd))
    expect_false(pd_is_root( 1, pd))
    expect_equal(sum(pd_is_root(pd$id, pd=pd)), 1)


    pd <- get_parse_data(parse(text={'{
        x <- rnorm(10, mean=0, sd=1)
        y <- runif(10)
        plot(x,y)
    }'}, keep.source=TRUE))
    expect_true(pd_is_root(68, pd), info="Grouping root")
    expect_true(pd_is_root(30, pd), info="Root within grouping.")
    expect_equal(sum(pd_is_root(pd$id, pd=pd)), 4)
    expect_equal(sum(pd_is_root(c(68, 30, 46, 62), pd)), 4)
    expect_false(pd_is_root(66, pd))

    expect_equal(sum(pd_is_root(pd$id, pd, ignore.groups=FALSE)), 1)
    expect_error(pd_is_root(0L, pd))

    pd[pd$parent %in% c(0,68) & pd$token == 'expr', ]
    expect_false(pd_is_root(30, pd, ignore.groups = FALSE))
    expect_equal(pd_is_root(c(68, 30), pd, ignore.groups = FALSE), c(TRUE, FALSE))

    pd <- get_parse_data(parse(text={"
        # a comment outside the grouping
        {# A grouping
        #' An Roxygen Comment
        hw <- function(){
            {# Another Grouping
             # but not a root since it is burried within a function
             1+2 #< an expression that is not a root.
            }
            3+4 #< also not a root
        }
        4+5 #< this is a root expression
        }
        6+7 #< a regular root expression
    "}, keep.source=TRUE))
    id <- max(pd[pd$token =="'{'", 'parent'])
    expect_true(pd_is_root(id, pd, ignore.groups = TRUE))
    id <- min(pd[pd$token =="'{'", 'parent'])
    expect_equal(get_family_pd(id, pd)[3,'text'], "# Another Grouping")

    ids <- pd[pd$token =="'{'", 'parent']
    expect_equal(pd_is_root(ids, pd, ignore.groups = TRUE ), c(TRUE, FALSE, FALSE))
    expect_equal(pd_is_root(ids, pd, ignore.groups = FALSE), c(TRUE, FALSE, FALSE))

    pd <- get_parse_data(parse(text="
        # a comment
        an_expression()
    ", keep.source=TRUE))
    expect_false(pd_is_root(pd[1,'id'], pd))
})
#line 151 "R/root.R"
test_that('roots', {#@testing
    pd <- get_parse_data(parse(text={"a <- 1
        {# section 1
        b <- 2
        {# section 2
        c <- 3
        }# end of section 1
        d <- 4
        }# end of section 2
        e <- 5
    "}, keep.source=TRUE))
    expect_equal(pd_all_root_ids(pd, TRUE), c(7, 52, 63))

    roots <- pd_all_root_ids(pd, FALSE)
    expect_equal(roots, c(7, 19, 31, 47, 63))
    expect_equal(getParseText(pd, roots), c('a <- 1','b <- 2', 'c <- 3', 'd <- 4', 'e <- 5'))

    pd <- get_parse_data(parse(text="
        # a comment
        an_expression()
    ", keep.source=TRUE))
    expect_equal( pd_all_root_ids(pd), -pd[1,'parent'])

    pd <- utils::getParseData(parse(text={"
    {# grouped code
        # normal comment
        #' Documenation before
        hw <- function(){
            #! documentation comment inside.
            print('hello world')
        }
    }
    {#Second Group
        1+2
    }
    # Comment 3
    4+5
    "}, keep.source=TRUE))
    id <- pd_all_root_ids(pd)
    expect_equal(id, c(43, 61, 74))
})
#line 209 "R/root.R"
test_that('all_root_nodes', {#!@testing
    pd <- get_parse_data(parse(text={"a <- 1
        {# section 1
        b <- 2
        {# section 2
        c <- 3
        }# end of section 1
        d <- 4
        }# end of section 2
        e <- 5
    "}, keep.source=TRUE))
    expect_equal(all_root_nodes(pd, TRUE)$id   , c(7, 52, 63))
    expect_equal(all_root_nodes(pd, TRUE)$line1, c(1,  2,  9))

    expect_equal(all_root_nodes(pd, FALSE)$id   , c(7, 19, 31, 47, 63))
    expect_equal(all_root_nodes(pd, FALSE)$line1, c(1,  3,  5,  7,  9))
})
#line 247 "R/root.R"
test_that('ascend_to_root', {#@testing
    pd <- get_parse_data(parse(text='rnorm(10, mean=0, sd=1)', keep.source=TRUE))
    expect_equal(ascend_to_root(id=23, pd), 23)
    expect_equal(ascend_to_root(id=1 , pd), 23)
    expect_identical(ascend_to_root(id=0, pd), 0L)

    pd <- get_parse_data(parse(text={"
        #' hello world
        hw <- function(){
            #! title
            print('hello world!')
        }
        #' comment after
    "}, keep.source=TRUE))
    expect_equal(ascend_to_root(3, pd), 34)
    expect_equal(ascend_to_root(pd$id, pd=pd), c(rep(34, 20), 0))

    pd <- get_parse_data(parse(text={"
    {   #' hello world
        hw <- function(){
            #! title
            print('hello world!')
        }
        #' comment after
    }"}, keep.source=TRUE))

    ascend_to_root(.find_text('hw'), pd)

    next_sibling(.find_text("#' hello world")) %>%
    is_root()
})