(import jinja2
        datetime
        [ib.core [date/previous-monday]])


(defn render [template environ]
  (apply .render
         [(-> (jinja2.Environment :loader (jinja2.FileSystemLoader "templates"))
             (.get-template template))]
         environ))

(defn this-week []
  (date/previous-monday (.date (datetime.datetime.now))))
