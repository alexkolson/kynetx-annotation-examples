ruleset a369x164 {
  meta {
    name "Annotation Via Event"
    description <<

    >>
    author "AKO"
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
          font-family: Impact,sans-serif; /* You should get the sad attempt at humor by now. */
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
          function fancy_event_annotate_callback(search_result, annotated_div, search_result_data) {
                  annotated_div.html(tasty_annotate_goodness);
                  $KOBJ(".annotate-inner", search_result).append("<br />" + "Horsty " + search_result_data.horsty);
                  annotated_div.show();
          }
      |>;

      annotate:annotate("annotation_via_event") with 
          annotator = <| fancy_event_annotate_callback |>
          and remote = "event";
   }
}

rule the_90s_called_they_want_their_static_web_back {
    select when web annotate_search name "annotation_via_event"
    foreach event:param("annotatedata").decode() setting (key, value)
    pre {
        this_annotation = event:param("annotate_instance");
    }
    if (value.pick("$.domain").match(re/bacon/i) || value.pick("$.url").match(re/horsty/i)) then {
        annotate:add_annotation_data(key, {"horsty":"likes pistachios"}, this_annotation);
    }
}
}
