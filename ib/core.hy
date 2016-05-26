(import datetime feedparser time itertools)


(defn date/previous-monday [when]
  "Given some random Python date, return the previous monday"
  (- when (datetime.timedelta :days (.weekday when))))

(defn date/from-struct_time [when]
  "Given a silly time.struct_time, turn it into a datetime.date"
  (datetime.date.fromtimestamp (time.mktime when)))

(defn date/parse [when]
  "Given a string-ish in YYYY-MM-DD, turn it into a date"
  (.date (datetime.datetime.strptime when "%Y_%m_%d")))

(defn date/parse-week [when]
  "Given a string-ish in YYYY-MM-DD, turn it into the date of the previous monday"
  (date/previous-monday (date/parse when)))

;;; 

(defn feed/from-rss [feed]
  "Parse an RSS feed into a feed dict"
  (map (fn [post] {"when"  (date/from-struct_time (. post ["published_parsed"]))
                   "title" (. post ["title"])
                   "url"   (. post ["id"])})
       (. (feedparser.parse feed) ["entries"])))

(defn feed/posts/by-week [when feed]
  "Get a list of posts that took place on the week of `when`"
  (filter (fn [post] (= (date/previous-monday (. post ["when"])) when)) feed))

;;;

(defn blogger/posts/by-week [when feeds]
  "Given a week constraint, and a feed, return all posts across all feeds"
  (apply itertools.chain
    (map (fn [feed] (feed/posts/by-week when feed))
         feeds)))
