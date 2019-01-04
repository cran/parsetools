
line_error <- function(id, msg, ..., pd=get('pd', parent.frame()))
    stop(filename(pd), ':', start_line(id, pd), ':  ', msg, ...)

line_error_if <- function(test, id, msg, ..., pd=get('pd', parent.frame()))
    if (force(test))
        stop(filename(pd), ':', start_line(id, pd), ':  ', msg, ...)

col_error <- function(id, msg, ..., pd=get('pd', parent.frame()))
    stop(filename(pd), ':', start_line(id, pd), ':', start_col(id, pd), ':  ', msg, ...)


if(FALSE){#@testing errors
    pd <- get_parse_data(parse(text='
    classDef <- setClass( "testClass"
         , slots = c( x="numeric" #< the x field
                    , y="matrix"  #< the y field
                    )
         )', keep.source=TRUE))

    id <- pd[pd$text == "#< the x field", 'id']

    expect_error(line_error(id, 'testing', pd=pd)
                , "<text>:3:  testing")
    expect_error(line_error_if(TRUE, id, 'testing', pd=pd)
                , "<text>:3:  testing")
    expect_error( col_error(id, 'testing col error', pd=pd)
                , "<text>:3:35:  testing col error")
    expect_silent(line_error_if(FALSE, id, 'testing', pd=pd))
    expect_null(line_error_if(FALSE, id, 'testing', pd=pd))
}
