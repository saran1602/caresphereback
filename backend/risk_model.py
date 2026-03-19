def predict_risk(sugar, bp, missed):

    # Convert BP string like "180/120" → systolic value 180
    if isinstance(bp, str):
        bp = int(bp.split("/")[0])

    sugar = int(sugar)
    missed = int(missed)

    score = sugar + bp + (missed * 30)

    if score > 500:
        return "CRITICAL"
    elif score > 350:
        return "HIGH"
    else:
        return "NORMAL"