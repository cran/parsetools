#! This file was automatically produced by the testextra package.
#! Changes will be overwritten.

context('tests extracted from file `get_parse_data.R`')
#line 45 "R/get_parse_data.R"
test_that('get_srcfile', {#@testing
    ex.file <- system.file("examples", "example.R", package="parsetools")
    exprs <- parse(ex.file, keep.source = TRUE)
    pd <- get_parse_data(exprs)

    sf <- attr(exprs, 'srcfile')
    expect_identical(get_srcfile(exprs), sf)
    attr(exprs, 'srcfile') <- NULL

    expect_identical(get_srcfile(exprs), sf)
    attr(exprs, "wholeSrcref") <- NULL

    expect_identical(get_srcfile(exprs), sf)
})
#line 101 "R/get_parse_data.R"
test_that('fix_eq_assign', {#! @testthat
    pd <- utils::getParseData(parse(text="a=1", keep.source=TRUE))
    fixed.pd <- fix_eq_assign(pd)
    expect_true('equal_assign'%in% fixed.pd$token)
    expect_true('EQ_ASSIGN'%in% fixed.pd$token)
    expect_that(sum(fixed.pd$parent==0), equals(1))
    expect_identical(fixed.pd, fix_eq_assign(fixed.pd))

    pd <- utils::getParseData(parse(text="a=1\nb<-2\nc=3\nd<<-4", keep.source=TRUE))
    fixed.pd <- fix_eq_assign(pd)
    expect_true('equal_assign'%in% fixed.pd$token)
    expect_true('EQ_ASSIGN'%in% fixed.pd$token)
    expect_that(sum(fixed.pd$parent==0), equals(4))
    expect_identical(fixed.pd, fix_eq_assign(fixed.pd))

    pd <- utils::getParseData(parse(text="a=b=1", keep.source=TRUE))
    fixed.pd <- fix_eq_assign(pd)
    expect_true('equal_assign'%in% fixed.pd$token)
    expect_true('EQ_ASSIGN'%in% fixed.pd$token)
    expect_that(sum(fixed.pd$parent==0), equals(1))
    expect_identical(fixed.pd, fix_eq_assign(fixed.pd))
})
#line 181 "R/get_parse_data.R"
test_that('get_parse_data.srcfile', {#@testing
    text <- "    my_function <- function(object #< An object to do something with
            ){
        #' A title
        #'
        #' A Description
        print(\"It Works!\")
        #< A return value.
    }"
    tmp <- tempfile()
    writeLines(text, tmp)

    readLines(tmp)
    source(tmp, keep.source = TRUE)

    srcref  <- utils::getSrcref(my_function)
    srcfile <- attr(srcref, 'srcfile')
    expect_equal(srcfile$filename, tmp)
    expect_is(srcfile$parseData, 'parseData')
    pd <- get_parse_data.srcfile(srcfile)
    expect_is(pd, 'parse-data', info = "srcfile with parseData")
    expect_identical(attr(pd, 'srcfile'), srcfile, info='carried forward srcfile')

    remove('parseData', envir = srcfile)
    expect_null(srcfile$parseData)
    expect_is(srcfile$lines, 'character')
    pd <- get_parse_data.srcfile(srcfile)
    expect_is(pd, 'parse-data', info = "srcfile from lines")

    remove('lines', envir = srcfile)
    expect_null(srcfile$parseData)
    expect_null(srcfile$lines, 'character')
    pd <- get_parse_data.srcfile(srcfile)
    expect_is(pd, 'parse-data', info = "srcfile from file directly")

    remove('filename', envir = srcfile)
    expect_error(get_parse_data.srcfile(srcfile), "could not retrieve parse-data for srcfile")

    unlink(tmp)
})
#line 245 "R/get_parse_data.R"
test_that('get_parse_data.srcref', {#@testing
    text <-{"my_function <-
        function( object #< An object to do something with
                ){
            #' A title
            #'
            #' A Description
            print('It Works!')
            #< A return value.
        }
        another_f <- function(){}
        if(F){}
    "}
    p <- parse(text=text, keep.source=TRUE)
    e <- new.env()
    eval(p, envir=e)
    srcref <- utils::getSrcref(e$my_function)
    srcfile <- get_srcfile(e$my_function)


    expect_is(srcref, 'srcref')
    pd <- get_parse_data.srcref(srcref)
    expect_is(pd, 'parse-data')
    expect_identical(attr(pd, 'srcfile'), srcfile)
})
#line 287 "R/get_parse_data.R"
test_that('get_parse_data.function basic', {#@test get_parse_data.function basic
test.text <-
"#' Roxygen Line Before
hw <-
function(x){
    #' line inside
    cat(\"hello world\")
}
another_fun <- function(){TRUE}
"
eval(parse(text=test.text, keep.source=TRUE))
x <- fun <- hw
pd.regular <- get_parse_data(hw)
expect_that(pd.regular, is_a("data.frame"))
expect_that(pd.regular[1,"text"], equals("#' Roxygen Line Before"))
})
#line 303 "R/get_parse_data.R"
test_that('get_parse_data.function grouped', {#@test get_parse_data.function grouped
grouped.text <-
"{#' Roxygen Line Before
hw <-
function(x){
    #' line inside
    cat(\"hello world\")
}}"
parsed <- parse(text=grouped.text, keep.source=TRUE)
raw.pd <- get_parse_data(parsed)
eval(parsed)
fun <- hw
pd <- get_parse_data(hw)
expect_is(pd, "parse-data")
expect_that(pd[1,"text"], equals("#' Roxygen Line Before"))
})
#line 319 "R/get_parse_data.R"
test_that('get_parse_data.function nested', {#@test get_parse_data.function nested
nested.text <-{
"{# Section Block
#' Roxygen Line Before
nested <-
function(x){
    #' line inside
    cat(\"hello world\")
}
}
"}
eval(parse(text=nested.text, keep.source=TRUE))
x <- fun <- nested
pd <- get_parse_data(nested)
expect_is(pd, "data.frame")
expect_is(pd, "parse-data")

# pd <- get_parse_data(function(){})
# expect_that(pd, is_a("data.frame"))
})
#line 339 "R/get_parse_data.R"
test_that('get_parse_data.function S4 Generic', {#@test get_parse_data.function S4 Generic
    # Note that testthat:::test_code will strip comments from code
    # this requires a parse & eval statement.
    p <- parse(text="setGeneric(\"my_generic\",
        function(object #< An object to do something with
                ){
            #' A title
            #'
            #' A Description
            print(\"It Works!\")
            #< A return value.
        })", keep.source=TRUE)
    eval(p)
    expect_null(utils::getParseData(my_generic))
    expect_true(isGeneric(fdef = my_generic))
    pd <- get_parse_data(my_generic)
    expect_is(pd, 'parse-data')
})
#line 357 "R/get_parse_data.R"
test_that('get_parse_data.function', {#@test get_parse_data.function
    p <- parse(text='setGeneric("test_generic",
        function(object
                ){
            value <- standardGeneric("test_generic")
        })', keep.source=TRUE)
    eval(p)
    expect_true(isGeneric(fdef = test_generic))
    expect_error( get_parse_data(test_generic)
                , "could not find the default method")
})
#line 386 "R/get_parse_data.R"
test_that('get_parse_data.default', {#@testing
    x <-
    exprs <- parse(text=c('x <- rnorm(10, mean=0, sd=1)'
                         ,'y <- mean(x)'
                         ), keep.source=TRUE)
    pd <- get_parse_data(exprs, keep.source=TRUE)
    expect_is(pd, 'parse-data', info = "get_parse_datwa.default with srcfile")


    expect_error(get_parse_data.default(datasets::iris)
                , "datasets::iris does not have a valid srcref\\.")
})
#line 401 "R/get_parse_data.R"
test_that('`subset.parse-data`', {#@testing
    pd <- get_parse_data(parse(text={
    "{# Section Block
    #' Roxygen Line Beore
    nested <-
    function(x){
        #' line inside
        cat(\"hello world\")
    }
    }
    "
    }, keep.source=TRUE))
    expect_is(pd, 'parse-data')
    pd2 <- pd[pd$line1 > 3, ]
    expect_is(pd2, 'parse-data')
    expect_equal(min(pd2$line1), 4)
})
#line 429 "R/get_parse_data.R"
test_that('`[.parse-data`', {#@testing
    pd       <- get_parse_data(parse(text='rnorm(10, mean=0, sd=1)', keep.source=TRUE))
    expect_is(pd, 'parse-data')
    expect_is(pd[pd$parent==0, ], 'parse-data')
    expect_false(methods::is(pd[pd$parent==0, 'id'], 'parse-data'))
})
#line 445 "R/get_parse_data.R"
test_that('`-.parse-data`', {#@test `-.parse-data`
pd <- get_parse_data(parse(text={
"{# Section Block
#' Roxygen Line Beore
nested <-
function(x){
    #' line inside
    cat(\"hello world\")
}
}
"
}, keep.source=TRUE))
comments <- nodes(all_comment_ids(pd))
expect_is(comments, 'parse-data')
clean.pd <- pd - comments

expect_is(clean.pd, 'parse-data')
expect_true(!any(comments$id %in% clean.pd$id))
})
#line 503 "R/get_parse_data.R"
test_that('as.data.frame.parseData', {#@testing
    if(F)
        debug(as.data.frame.parseData)
    p <- parse(text={"
    my_function <- function(object #< An object to do something with
            ){
        #' A title
        #'
        #' A Description
        print(\"It Works!\")
        #< A return value.
    }"}, keep.source=TRUE)
    srcfile <- attr(p, 'srcfile')
    x <- srcfile$parseData

    df1 <- as.data.frame.parseData(x, srcfile=srcfile)
    expect_true(valid_parse_data(df1))
})
#line 539 "R/get_parse_data.R"
test_that('valid_parse_data', {#@testing
    df <- utils::getParseData(parse(text="rnorm(10,0,1)", keep.source=TRUE))
    expect_true (valid_parse_data(df), 'parse-data')
    expect_equal(valid_parse_data(datasets::iris      ), "names of data do not conform.")
    expect_equal(valid_parse_data(stats::rnorm(10,0,1)), "Not a data.frame object")
})
#line 563 "R/get_parse_data.R"
test_that('as_parse_data', {#@testing
    df <- utils::getParseData(parse(text="rnorm(10,0,1)", keep.source=TRUE))
    expect_is   (as_parse_data(df), 'parse-data')
    expect_error(as_parse_data(datasets::iris), "Cannot convert to parse-data: names of data do not conform.")
    expect_error(as_parse_data(stats::rnorm(10,0,1)), "Cannot convert to parse-data: Not a data.frame object")
})
