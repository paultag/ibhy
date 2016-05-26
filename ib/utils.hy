(import jinja2)


(defn render [template environ]
  (apply .render
         [(-> (jinja2.Environment :loader (jinja2.FileSystemLoader "templates"))
             (.get-template template))]
         environ))
