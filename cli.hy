(import sys json
        [ib.core [date/parse-week]]
        [ib.utils [render this-week]]
        [ib.iron-blogger [iron-bloggers-report iron-bloggers/slackers]]
        [bloggers [bloggers]])




; (print (render "mail.j2" {"report" report
;                           "slackers" (iron-bloggers/slackers report)}))

(defn ! [iter] (for [- iter] (do 1)))


(defn generate-report [path]
  (with [[fd (open path "w")]]
    (json.dump (list (iron-bloggers-report (this-week) bloggers)) fd)))


(defn read-report-from-file [path]
  (with [[fd (open path "r")]]
    (json.load fd)))

(defn ledger-debt [when uid amount]
  (apply .format ["{when:%Y-%m-%d} Week of {when:%Y-%m-%d}
  User:{uid}     {amount}
  Pool:Owed:{uid}
"] {"when" when
                     "uid" uid
                     "amount" amount}))

(defn debt-slacker [ledger-path when uid]
  (with [[fd (open ledger-path "a")]]
    (fd.write (ledger-debt when uid -5))))

(defn debt-slackers [when report-path ledger-path]
  (! (map (fn [who] (debt-slacker ledger-path (date/parse-week when) who))
     (iron-bloggers/slackers (read-report-from-file report-path)))))


(defn main [command &rest args]
  (apply (get {"generate-report" generate-report
               "debt-slackers" debt-slackers} command) args))

(apply main (slice sys.argv 1))
