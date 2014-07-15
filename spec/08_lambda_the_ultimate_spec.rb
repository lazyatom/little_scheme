describe 'a little Scheme' do
  context 'according to chapter eight of The Little Schemer' do
    include SyntaxMatchers
    include SemanticsMatchers

    describe "rember-f" do
      define :>, '(lambda (n m) (cond ((zero? n) #f) ((zero? m) #t) (else (> (sub1 n) (sub1 m)))))'
      define :<, '(lambda (n m) (cond ((zero? m) #f) ((zero? n) #t) (else (< (sub1 n) (sub1 m)))))'
      define :'=', '(lambda (n m) (cond ((> n m) #f) ((< n m) #f) (else #t)))'
      define :eqan?, '(lambda (a1 a2) (cond ((and (number? a1) (number? a2)) (= a1 a2)) ((or (number? a1) (number? a2)) #f) (else (eq? a1 a2))))'
      define :eqlist?, '(lambda (l1 l2) (cond ((and (null? l1) (null? l2)) #t) ((or (null? l1) (null? l2)) #f) ((and (atom? (car l1)) (atom? (car l2))) (and (eqan? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2)))) ((or (atom? (car l1)) (atom? (car l2))) #f) (else (and (eqlist? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2))))))'
      define :equal?, '(lambda (s1 s2) (cond ((and (atom? s1) (atom? s2)) (eqan? s1 s2)) ((or (atom? s1) (atom? s2)) #f) (else (eqlist? s1 s2))))'
      define :'rember-f', '(lambda (test? a l) (cond ((null? l) (quote ())) (else (cond ((test? (car l) a) (cdr l)) (else (cons (car l) (rember-f test? a (cdr l))))))))'

      specify { expect('(rember-f test? a l)').to evaluate_to('(6 2 3)').where l: '(6 2 5 3)', test?: '=', a: '5' }
      specify { expect('(rember-f test? a l)').to evaluate_to('(beans are good)').where l: '(jelly beans are good)', test?: 'eq?', a: 'jelly' }
      specify { expect('(rember-f test? a l)').to evaluate_to('(lemonade and (cake))').where l: '(lemonade (pop corn) and (cake))', test?: 'equal?', a: '(pop corn)' }
    end

    describe "rember-f (short version)" do
      define :>, '(lambda (n m) (cond ((zero? n) #f) ((zero? m) #t) (else (> (sub1 n) (sub1 m)))))'
      define :<, '(lambda (n m) (cond ((zero? m) #f) ((zero? n) #t) (else (< (sub1 n) (sub1 m)))))'
      define :'=', '(lambda (n m) (cond ((> n m) #f) ((< n m) #f) (else #t)))'
      define :eqan?, '(lambda (a1 a2) (cond ((and (number? a1) (number? a2)) (= a1 a2)) ((or (number? a1) (number? a2)) #f) (else (eq? a1 a2))))'
      define :eqlist?, '(lambda (l1 l2) (cond ((and (null? l1) (null? l2)) #t) ((or (null? l1) (null? l2)) #f) ((and (atom? (car l1)) (atom? (car l2))) (and (eqan? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2)))) ((or (atom? (car l1)) (atom? (car l2))) #f) (else (and (eqlist? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2))))))'
      define :equal?, '(lambda (s1 s2) (cond ((and (atom? s1) (atom? s2)) (eqan? s1 s2)) ((or (atom? s1) (atom? s2)) #f) (else (eqlist? s1 s2))))'
      define :'rember-f', '(lambda (test? a l) (cond ((null? l) (quote ())) ((test? (car l) a) (cdr l)) (else  (cons (car l) (rember-f test? a (cdr l))))))'

      specify { expect('(rember-f test? a l)').to evaluate_to('(6 2 3)').where l: '(6 2 5 3)', test?: '=', a: '5' }
      specify { expect('(rember-f test? a l)').to evaluate_to('(beans are good)').where l: '(jelly beans are good)', test?: 'eq?', a: 'jelly' }
      specify { expect('(rember-f test? a l)').to evaluate_to('(lemonade and (cake))').where l: '(lemonade (pop corn) and (cake))', test?: 'equal?', a: '(pop corn)' }
    end

    # The book doesn't test define, but we will.
    describe "define" do
      define :+, '(lambda (n m) (cond ((zero? m) n) (else (add1 (+ n (sub1 m))))))'
      define :<, '(lambda (n m) (cond ((zero? m) #f) ((zero? n) #t) (else (< (sub1 n) (sub1 m)))))'

      evaluate '(define first (lambda (list) (car list)))'

      specify { expect('(first x)').to evaluate_to('1').where x: '(1 2 3)' }

      evaluate '(define less-than (lambda (x) (lambda (y) (< y x))))'
      evaluate '(define less-than-5 (less-than 5))'

      specify { expect('(less-than-5 x)').to evaluate_to('#t').where x: '4' }

      evaluate '(define plus-something (lambda (x) (lambda (y) (+ x y))))'
      evaluate '(define plus-1 (plus-something 1))'

      specify { expect('(plus-1 x)').to evaluate_to('5').where x: '4' }
    end

    describe "eq?-c" do
      evaluate '(define eq?-c (lambda (a) (lambda (x) (eq? x a))))'

      specify { pending 'not sure how to compare lambdas'; expect('(eq?-c k)').to evaluate_to('(lambda (x) (eq? x salad))').where k: 'salad' }
    end

    describe "eq?-salad" do
      evaluate '(define eq?-c (lambda (a) (lambda (x) (eq? x a))))'
      evaluate '(define eq?-salad (eq?-c k))', k: 'salad'

      specify { expect('(eq?-salad y)').to evaluate_to('#t').where y: 'salad' }
      specify { expect('(eq?-salad y)').to evaluate_to('#f').where y: 'tuna' }
      specify { expect('((eq?-c x) y)').to evaluate_to('#f').where x: 'salad', y: 'tuna' }
    end

    describe "rember-f" do
      define :>, '(lambda (n m) (cond ((zero? n) #f) ((zero? m) #t) (else (> (sub1 n) (sub1 m)))))'
      define :<, '(lambda (n m) (cond ((zero? m) #f) ((zero? n) #t) (else (< (sub1 n) (sub1 m)))))'
      define :'=', '(lambda (n m) (cond ((> n m) #f) ((< n m) #f) (else #t)))'
      define :eqan?, '(lambda (a1 a2) (cond ((and (number? a1) (number? a2)) (= a1 a2)) ((or (number? a1) (number? a2)) #f) (else (eq? a1 a2))))'
      define :eqlist?, '(lambda (l1 l2) (cond ((and (null? l1) (null? l2)) #t) ((or (null? l1) (null? l2)) #f) ((and (atom? (car l1)) (atom? (car l2))) (and (eqan? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2)))) ((or (atom? (car l1)) (atom? (car l2))) #f) (else (and (eqlist? (car l1) (car l2)) (eqlist? (cdr l1) (cdr l2))))))'
      define :equal?, '(lambda (s1 s2) (cond ((and (atom? s1) (atom? s2)) (eqan? s1 s2)) ((or (atom? s1) (atom? s2)) #f) (else (eqlist? s1 s2))))'
      evaluate '(define rember-f (lambda (test?) (lambda (a l) (cond ((null? l) (quote ())) ((test? (car l) a) (cdr l)) (else  (cons (car l) (rember-f test? a (cdr l))))))))'

    end
  end
end
