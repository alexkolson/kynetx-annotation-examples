ruleset a163x57 {
  meta {
    name "Remote annotation example"
    description <<
        Search annotation example using a remote datasource
    >>
    author "snay, ako"
    logging off
  }

  dispatch {
    domain "google.com"
    domain "bing.com"
    domain "yahoo.com"
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
            font-family: Impact,sans-serif; /* pun intended. ha. haha. I'm so funny. */
            float: right;
        }
    >>;
  }

  rule search_annotate_rule is active {
    select using "google.com|bing.com/search|search.yahoo.com/search" 
        emit <<
            function remote_annotation_callback(search_result, annotated_div, data) {
                var annotation_html = '<div class = "annotate"><div class = "annotate-inner">';
                if (typeof(data.horsty) !== "undefined") {
                    annotation_html += "Horsty " + data.horsty + ", ";
                    annotation_html += "but Horstmeier " + data.horstmeier + ".";
                    annotation_html += "</div></div>";
                    annotated_div.html(annotation_html);
                } else if (typeof(data.bacon) !== "undefined") {
                    annotation_html += "bacon " + data.bacon + ", ";
                    annotation_html += "and pig " + data.pig + ".";
                    annotated_div.html(annotation_html);
                } else {
                    // the user is not searching for bacon or horsty and therfore is not worthy
                    // to feast their eyes on an annotation
                }
                
                annotated_div.show();
            }
        >>;

        annotate:annotate("remote_annotation") with 
            annotator = <| remote_annotation_callback |> and
            remote = "http://www.alexkolson.com/remote_annotation_kynetx.php?jsoncallback=?";
  }
}
