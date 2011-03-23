ruleset a163x56 {
  meta {
    name "Simple search annotation example"
    description <<
        Simple search annotation example
    >>
    author "snay, ako"
    logging off
  }

  dispatch {
    domain "google.com"
    domain "yahoo.com"
    domain "bing.com"
  }

  global {
    css <<
        div.annotate {
            margin: 3px;
        }
        div.annotate-inner {
            border: 1px solid red;
            border-radius: 3px;
            -moz-border-radius: 3px;
            padding: 2px 10px;
            font-family: Impact,sans-serif; /* Pun intented. Ha haha. I'm so funny. */
            float: right;
        }
    >>;
  }

  rule search_annotate_func is active {
     select when pageview "google.com|bing.com/search|search.yahoo.com/search" 
     pre {
         tasty_annotate_goodness = <<
            <div class = "annotate">
                <div class = "annotate-inner">
                    An annotation!
                </div>
            </div>
         >>;
     }
     {
        emit <|
            function basic_annotate_callback(search_result, annotated_div, search_result_data) {
                if (search_result_data.domain.match(/bacon/i) || search_result_data.url.match(/horsty/i)) {
                    annotated_div.html(tasty_annotate_goodness);
                    annotated_div.show();
                }
            }
        |>;
  
        annotate:annotate("basic_annotation_with_javascript_callback") with 
            annotator = <| basic_annotate_callback |>;
     }
  }
  
}
