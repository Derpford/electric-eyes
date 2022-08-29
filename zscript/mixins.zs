mixin class Randoms {
    // Helpful functions for randomness.
    int WeightedRandom(Array<Double> weights) {
        double sum;
        for (int i = 0; i < weights.size(); i++) {
            sum += weights[i];
        }

        // And now we roll.
        double roll = frandom(0,sum);
        for (int i = 0; i < weights.size(); i++) {
            if (roll < weights[i]) {
                return i;
            } else {
                roll -= weights[i];
            }
        }
        // If we reach this point, something went wrong.
        return -1;
    }

    string WRDict(Dictionary items) {
        Array<String> names;
        Array<Double> weights;
        DictionaryIterator it = DictionaryIterator.create(items);
        while (it.next()) {
            names.push(it.key());
            weights.push(it.value().toDouble());
        }

        int res = WeightedRandom(weights);
        if (res == -1) {
            ThrowAbortException("Bad result from weighted random!");
        }

        return names[res];
    }

    string Pick(Array<String> items) {
        return items[random(0,items.size())];
    }
}