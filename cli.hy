(import datetime
        [ib.utils [render]]
        [ib.iron-blogger [iron-bloggers-report iron-bloggers/slackers]]
        [ib.core [date/parse-week date/previous-monday]])

(setv iron-bloggers
  '((paultag            2010-01-01 (("http://blog.pault.ag/rss" :rss)
                                    ("http://notes.pault.ag/feeds/all-en.rss.xml" :rss)))
    (peter-reinholdtsen 1800-01-01 (("http://people.skolelinux.org/pere/blog/tags/english/english.rss" :rss)))
    (zobel              2020-02-02 (("http://blog.zobel.ftbfs.de/rss.xml" :rss)))
    (corsec             2010-01-01 (("http://www.corsac.net/rss.php?cat=debian" :rss)))))


(defn this-week []
  (date/previous-monday (.date (datetime.datetime.now))))


(defn this-weeks-report []
  (list (iron-bloggers-report (this-week) iron-bloggers)))


(setv report (this-weeks-report))

(print (render "mail.j2" {"report" report "slackers" (iron-bloggers/slackers report)}))
