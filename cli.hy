(import sys json
        [ib [date/parse-week date/parse render this-week iron-bloggers-report iron-bloggers/slackers]]
        [bloggers [bloggers]])


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


(defn ledger-payment [when uid amount]
  (apply .format ["{when:%Y-%m-%d} Payment into the Pool
  Pool:Owed:{uid}     {amount}
  Pool:Paid
"] {"when" when
    "uid" uid
    "amount" amount}))


(defn debt-slacker [ledger-path when uid]
  (with [[fd (open ledger-path "a")]]
    (fd.write (ledger-debt when uid -5))))


(defn debt-slackers [when report-path ledger-path]
  (! (map (fn [who] (debt-slacker ledger-path (date/parse-week when) who))
     (iron-bloggers/slackers (read-report-from-file report-path)))))


(defn email-template-from-report [when report]
  (render "mail.j2" {"report" report
                     "slackers" (iron-bloggers/slackers report)
                     "when" when}))


(defn payment [when uid amount ledger-path]
  (with [[fd (open ledger-path "a")]]
    (fd.write (ledger-payment (date/parse when) uid amount))))


(defn email-template [when report-path output-path]
  (with [[fd (open output-path "w")]]
    (fd.write (email-template-from-report
                (date/parse-week when)
                (read-report-from-file report-path)))))


(defn main [command &rest args]
  (apply (get {"generate-report" generate-report
               "generate-email" email-template
               "payment" payment
               "debt-slackers" debt-slackers} command) args))


(apply main (slice sys.argv 1))
