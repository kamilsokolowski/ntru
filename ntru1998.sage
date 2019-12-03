import random

#Parameters
n = 503

p = 3
q = 256
prime = 2
df = 100
dg = 100
dr = 100
dm = 100

gen_t = []
enc_t = []
dec_t = []

Z.<x> = ZZ[]

#Ternary polyonomianl generating function.
def poli(d1, d2, N):
    lp = [i for i in range(N)]
    p = [0 for i in range(N)]
    ld1 = 0
    ld2 = 0
    while(d1 != ld1):
        tmp1 = random.choice(lp)
        element = p[tmp1]
        if element != 1 and element != -1:
            p[tmp1] = 1
            ld1 = ld1 + 1
    while(d2 != ld2):
        tmp2 = random.choice(lp)
        element = p[tmp2]
        if element != 1 and element != -1:
            p[tmp2] = -1
            ld2 = ld2 + 1
    return p

#Central lift function defined as clf: Fq -> RN
def clf(f, q, n):
    g = list(((f[i] + q//2) % q) - q//2 for i in range(n))
    return Z(g)

#Function that finds polynominal invers mod p
def invertmodprime(f, p):
    Zp = Z.change_ring(Integers(p))
    T = Zp.quotient((x**n)-1, names='x')
    return Z(lift(1 / T(f)))

#Function that finds polynominal invers mod p^k
def invertmodpowerofprime(f, q, n, _prime):
    assert q.is_power_of(_prime)
    g = invertmodprime(f, _prime)
    while True:
        r = clf(g * f % (x^n-1), q, n)
        if r == 1: return g
        g = clf((g * (_prime - r)) % (x^n-1), q, n)

#Key generation function returns set (priv, pub).
def gen():
    f, g = Z(poli(df + 1, df, n)), Z(poli(dg, dg, n))
    fp_i = invertmodprime(f, p)
    fq_i = invertmodpowerofprime(f, q, n, prime)
    h = clf(p * ((fq_i * g) % (x^n-1)), q, n)
    return ((f, fp_i), h) # priv, pub

#Encryption function returnes ciphertext e.
def enc(pub, m):
    r = Z(poli(dr, dr, n))
    e = clf(((pub * r) % (x^n-1)) + m, q, n)
    return e

#Decryption function returnes decrypted message m.
def dec(priv, e):
    fq, fp_i = priv
    a = clf((e * fq % (x^n-1)), q, n)
    m = clf((a * fp_i % (x^n-1)), p, n)
    return m

#Example of usage. Single cycle of generation, encryption and decryption.
#GENERATING

#priv, pub = key_gen()

#ENCRYPTION
#m = poli(dm, N)

#e = enc(pub, m)
#DECRYPTION

#m_decrypted = dec(priv, e)
