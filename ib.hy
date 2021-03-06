(import datetime feedparser time itertools jinja2 pytz [email.utils [parsedate]])


(defn date/previous-monday [when]
  "Given some random Python date, return the previous monday"
  (- when (datetime.timedelta :days (.weekday when))))

(defn vprint [body]
  (print body)
  body)

(defn date/parse [when]
  "Given a string-ish in YYYY-MM-DD, turn it into a date"
  (.date (datetime.datetime.strptime when "%Y_%m_%d")))

(defn date/parse-week [when]
  "Given a string-ish in YYYY-MM-DD, turn it into the date of the previous monday"
  (date/previous-monday (date/parse when)))

;;; 


(defn date/from-timestamp [when]
  (.date (datetime.datetime.fromtimestamp (time.mktime (parsedate when)))))


(defn feed/from-rss [feed]
  "Parse an RSS feed into a feed dict"
  (map (fn [post] {"when"  (date/from-timestamp (. post ["published"]))
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


(defn iron-blogger-report/parse-feed [(, feed type)]
  "Take an iron-blogger feed def (2-tuple, URL and type), and return a feed list"
  ((get {:rss feed/from-rss} type) feed))

(defn iron-blogger-report/parse-feeds [feeds]
  "Take an iron-blogger feed defs (list of 2-tuple) and return a list of feeds"
  (map iron-blogger-report/parse-feed feeds))

(defn iron-blogger-report [when who feeds]
  "Given a week, and a list of feeds, return a tuple of (who, posts) for a week"
  (, who (list (blogger/posts/by-week when (iron-blogger-report/parse-feeds feeds)))))

(defn iron-bloggers-report/started? [when (, - start-date -)]
  "Check to see if the date is before or after their start date"
  (<= (date/parse-week start-date) when))

(defn iron-bloggers-report [when bloggers]
  "Given a list of iron bloggers, make an iron blogger post report"
  (map (fn [(, who start-date feeds)] (iron-blogger-report when who feeds))
       (filter (fn [x] (iron-bloggers-report/started? when x)) bloggers)))

(defn iron-bloggers/slackers [report]
  "Given an iron blogger post report, determine who slacked"
  (map (fn [(, who posts)] who)
       (filter (fn [(, who posts)] (= 0 (len (list posts)))) report)))


(defn render [template environ]
  (apply .render
         [(-> (jinja2.Environment :loader (jinja2.FileSystemLoader "templates"))
             (.get-template template))]
         environ))

(defn this-week []
  (date/previous-monday (.date (datetime.datetime.utcnow))))

(defn last-week []
  (- (this-week) (datetime.timedelta :days 7)))
