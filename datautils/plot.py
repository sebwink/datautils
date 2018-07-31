import seaborn as sns

def distplot(data, col, lb=None, ub=None):
    if lb is None and ub is None:
        sns.distplot(data[col])
    if ub is None:
        sns.distplot(data[data[col]>lb][col])
    if lb is None:
        sns.distplot(data[data[col]<ub][col])
    else:
        sns.distplot(data[(data[col]>lb)&(data[col]<ub)][col])
