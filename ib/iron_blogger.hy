(import [ib.core [feed/from-rss blogger/posts/by-week date/parse-week]])


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
  (< (date/parse-week start-date) when))

(defn iron-bloggers-report [when bloggers]
  "Given a list of iron bloggers, make an iron blogger post report"
  (map (fn [(, who start-date feeds)] (iron-blogger-report when who feeds))
       (filter (fn [x] (iron-bloggers-report/started? when x)) bloggers)))

(defn iron-bloggers/slackers [report]
  "Given an iron blogger post report, determine who slacked"
  (map (fn [(, who posts)] who)
       (filter (fn [(, who posts)] (= 0 (len (list posts)))) report)))
