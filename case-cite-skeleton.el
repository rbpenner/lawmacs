;; not yet in use
(defconst legal-db-codes
  '("WL" "LEXIS")
  "List of electronic legal database citation codes. 
For use in applying special treatment to short forms.
  
See _The Bluebook: A Uniform System of Citation_ R. 10.9(a)(2), at 116 
\(Colombia Law Review Ass'n et al. eds., 20th ed. 2015).")

;; the main function
(define-skeleton case-cite-skeleton
  "Inserts a case citation and creates abbrevs for inserting the cite in long and short forms"

;; TODO's: 
  ;; make point appear after v2 after long cite abbrev expands
  ;; get reporter abbrevs to expand when entering into skeleton
  ;; replace test for "WL" with general test for all electronic dbs defined in variable 'legal-db-codes'
  ;; facility for re-running abbrev creation when this function is modified/extended
  ;; conditional to delete extra "/" when expanding after an introductory signal
  ;; test for existing abbrev with same name and prompt to overwrite or rename
  
  nil
  "/" (setq v1 (skeleton-read "Case Name: ")) "/, "       ;case name
  (setq v2 (skeleton-read "Main reporter cite: "))	  ;reporter
  ("pincite: " ", " str)		       	          ;pincite
  resume:
  " (" (setq v3 (skeleton-read "court and date: ")) ")"   ;date
			     		;parenthetical
  '(setq case-abbrev-trigger (skeleton-read "abbrev trigger: ")
	 short-case-name (skeleton-read "short case name: ")
	 v2-split (split-string v2))
  ;; Define abbrev for full citations
  (define-abbrev
    global-abbrev-table
    case-abbrev-trigger
    (concat "/" v1 "/, " v2 " (" v3 ")"))
  ;; Define abbrev for short form citations
  (define-abbrev
    global-abbrev-table
    (concat case-abbrev-trigger "sh")
    (concat "/"
	    short-case-name
	    "/, "
	    (if (member "WL" v2-split) v2 (combine-and-quote-strings (butlast (split-string v2))))
	    " at"))
  ;; Define abbrev for short case names in textual sentences
  (define-abbrev
    global-abbrev-table
    (concat case-abbrev-trigger "n")
    (concat "/" short-case-name "/")))

