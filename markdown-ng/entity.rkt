#lang racket/base

(require "parsack.rkt")

(provide $entity)

(define $char-entity/dec
  (try (pdo (x <- (many1 $digit))
            (char #\;)
            (return (string->number (list->string x) 10)))))

(define $char-entity/hex
  (try (pdo (<or> (char #\x)
                  (char #\X))
            (x <- (many1 $hexDigit))
            (char #\;)
            (return (string->number (list->string x) 16)))))

(define $char-entity
  (try (>> (char #\#)
           (<or> $char-entity/dec
                 $char-entity/hex))))

(define $sym-entity
  (try (pdo (x <- (many1 (<or> $letter $digit)))
            (char #\;)
            (return (string->symbol (list->string x))))))

(define $not-entity
  (return "&")) ;; not 'amp -- act like xexpr

(define $entity
  (>> (char #\&)
      (<or> $char-entity
            $sym-entity
            $not-entity)))
