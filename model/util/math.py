class Math:

    @classmethod
    def isEquivalent(cls, a, b, precision=5):
        maxDiff = (10 ** -(precision)) - 10 ** -(precision+1)
        diff = abs(a-b)
        return diff < maxDiff