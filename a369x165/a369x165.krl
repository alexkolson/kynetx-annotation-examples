ruleset a369x165 {
  meta {
    name "Extending annotation"
    description <<

    >>
    author ""
    logging off
  }
  dispatch {
  domain "facebook.com"
  domain "stackoverflow.com"
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
          font-family: Impact,sans-serif; /* Yeah now this is just old and stupid. */
          float: right;
      }
  >>;
}

rule search_annotate_func is active {
   select when pageview "facebook.com" 
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
          var i = 0; // counter for demo purposes
          
          function extract_fb_data(news_item, config) {
              var poster_name = $K(".actorName > a:eq(0)", news_item).text();
              var post_source = "";
              // check for a post source other than facebook
              if ($K(".uiStreamSource > a:eq(1)", news_item).length) {
                post_source = $K(".uiStreamSource > a:eq(1)", news_item).text();
              } else {
                  post_source = "facebook";
              }
              
              var post_time = $K(".uiStreamSource > a:eq(0) > abbr", news_item).attr("data-date");
              
              return {"author": poster_name, "source": post_source, "time": post_time};
          }
              
          function custom_annotate_callback(fb_post, annotated_div, fb_post_data) {
              KOBJ.log("annotate callback called. It has been called " + (i + 1) + " times so far");
              if (fb_post_data.author.match(/grace/i) || fb_post_data.source.match(/twitter/i)) {
                  annotated_div.html(tasty_annotate_goodness);
                  $K(".annotate-inner", annotated_div).append("<br />" + fb_post_data.time);
                  annotated_div.show();
              }
              ++i;
          }
      |>;

      annotate:annotate("custom_annotate_facebook") with 
          annotator = <| custom_annotate_callback |>
          and domains = {
                            "fb_override": {
                                "selector": "#home_stream > li",
                                "modify": ".storyInnerContent",
                                "watcher": "#home_stream",
                                "extract_function": extract_fb_data
                            }
                        }
          and domain_override = "fb_override";
   }
}

rule annotate_stackoverflow {
    select when pageview "stackoverflow.com"
    {
        emit <|
            function extract_so_data(question, config) {
                var question_title = $K(".summary > h3:eq(0) > a", question).text();
                var question_tags = [];
                $K(".summary .tags > a", question).each(function(i, tag) {
                    question_tags.push($K(tag).text());
                });
                var timestamp = $K(".summary .relativetime", question).attr("title");
                var nice_time = $K(".summary .relativetime", question).text();
                var last_active_user = $K(".summaruy .started > a:eq(1)", question).text();
                var last_active_user_reputation = $K(".summary .reputation-score", question).text();
                var is_answered = $K(".status", question).hasClass("answered");
                
                return {
                    "title": question_title, 
                    "tags": question_tags, 
                    "time": {
                        "stamp": timestamp, 
                        "nice_string": nice_time
                    }, 
                    "last_active_user": {
                        "name": last_active_user, 
                        "reputation": last_active_user_reputation
                    }, 
                    "answered": is_answered
                };
            }
            
            function annotate_so_callback(question, decorator, question_data) {
                // if the question is unanswered and the asker has a reputation above 150, 
                // annotate it
                if (!question_data.answered && question_data.last_active_user.reputation > 150) {
                    decorator.html('<div class = "annotate"><div class = "annotate-inner">You should answer this one.</div></div>');
                    decorator.show();
                }
            }
        |>;
        
        annotate:annotate("custom_so_annotation") with
            annotator = <| annotate_so_callback |> and
            domains = {
                "stackoverflow.com": {
                    "selector": "#question-mini-list > div",
                    "modify": ".tags",
                    "extract_function": extract_so_data
                }
            };
    }
}
}