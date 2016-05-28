(import [ib.utils [render this-week]]
        [ib.iron-blogger [iron-bloggers-report iron-bloggers/slackers]]
        [bloggers [bloggers]])



(defn this-weeks-report []
  (list (iron-bloggers-report (this-week) bloggers)))


(setv report (this-weeks-report))

(print (render "mail.j2" {"report" report
                          "slackers" (iron-bloggers/slackers report)}))
