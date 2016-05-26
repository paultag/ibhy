(import datetime feedparser time functools itertools)


(defn date/previous-monday [when]
  (- when (datetime.timedelta :days (.weekday when))))

(defn date/from-struct_time [when]
  (datetime.date.fromtimestamp (time.mktime when)))

(defn date/parse [when]
  (.date (datetime.datetime.strptime when "%Y_%m_%d")))

(defn date/parse-week [when]
  (date/previous-monday (date/parse when)))

;;; 

(defn feed/from-rss [feed]
  (map (fn [post] {"when"  (date/from-struct_time (. post ["published_parsed"]))
                   "title" (. post ["title"])
                   "url"   (. post ["id"])})
       (. (feedparser.parse feed) ["entries"])))

(defn feed/posts/by-week [when feed]
  (filter (fn [post] (= (date/previous-monday (. post ["when"])) when)) feed))

(defn feed/posted? [when feed]
  (any (feed/posts/by-week when feed)))

(defn feed/slacked? [when feeds]
  (not (any (map (fn [x] (feed/posted? when x)) feeds))))

(defn feeds/from-rss [feeds]
  (map feed/from-rss feeds))

;;;

(defn blogger/posts/by-week [when feeds]
  (apply itertools.chain
    (map (fn [feed] (feed/posts/by-week when feed))
         feeds)))

;;; 

(defn iron-blogger-report/parse-feed [(, feed type)]
  ((get {:rss feed/from-rss} type) feed))

(defn iron-blogger-report/parse-feeds [feeds]
  (map iron-blogger-report/parse-feed feeds))

(defn iron-blogger-report [when who feeds]
  (, who (list (blogger/posts/by-week when (iron-blogger-report/parse-feeds feeds)))))

(defn iron-bloggers-report/started? [when (, - start-date -)]
  (< (date/parse-week start-date) when))

(defn iron-bloggers-report [when bloggers]
  (map (fn [(, who start-date feeds)] (iron-blogger-report when who feeds))
       (filter (fn [x] (iron-bloggers-report/started? when x)) bloggers)))


;;

(defn iron-bloggers/slackers [report]
  (map (fn [(, who posts)] who)
       (filter (fn [(, who posts)] (= 0 (len (list posts)))) report)))


(print (list (iron-bloggers/slackers
  (iron-bloggers-report
    (date/parse-week '2014-08-15)
    '((paultag 2010-01-01 (("http://blog.pault.ag/rss" :rss)
                             ("http://notes.pault.ag/feeds/all-en.rss.xml" :rss)))
      (zobel   2020-02-02 (("http://blog.zobel.ftbfs.de/rss.xml" :rss)))
      (corsec  2010-01-01 (("http://www.corsac.net/rss.php?cat=debian" :rss))))))))
