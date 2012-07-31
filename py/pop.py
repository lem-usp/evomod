import numpy as np


class Individual:
    """class for Individuals in a Population"""
    def __init__(self, m, p, amb, mu, mu_b, sigma):
        self.m = m                # number of loci
        self.p = p                # number of traits
        self.amb = amb            # environmental noise
        self.mu = mu              # genetic effects mutation rate
        self.mu_b = mu_b          # ontogenetic effects mutation rate
        self.sigma = sigma        # genetic mutation variance

    def generate(self):
        """creates an ind with Individual parameters"""
        b = np.zeros((self.p, 2 * self.m),
                     dtype=float)              # binary ontogenetic matrix
        y = np.zeros(2 * self.m, dtype=float)  # gene vector
        x = np.dot(b, y)                       # additive effects vector
        z = x + np.random.normal(0, self.amb,
                                 self.p)       # phenotipic values vector
        return {'y': y, 'x': x, 'z': z, 'b': b}

    def mutate(self, ind):
        """Mutates an ind with Individual parameters"""
        mutation_number_y = np.random.binomial(2 * self.m, self.mu)
        if (mutation_number_y > 0):
            mutation_vector = np.concatenate((
                np.random.normal(self.sigma, size=mutation_number_y),
                np.zeros(2 * self.m - mutation_number_y)))
            np.random.shuffle(mutation_vector)
            ind['y'] = ind['y'] + mutation_vector
        mutation_number_b = np.random.binomial(2 * self.m * self.p,
                                               self.mu_b)
        if (mutation_number_b > 0):
            mutation_mask = np.concatenate((
                np.ones(mutation_number_b),
                np.zeros(2 * self.m * self.p - mutation_number_b)))
            np.random.shuffle(mutation_mask)
            mutation_mask = mutation_mask.reshape((self.p, 2 * self.m))
            ind['b'] = (ind['b'] + mutation_mask) % 2

    def fitness(self, ind, omega, teta):
        """calculates ind fitness from population"""
        delta_s = ind['z'] - teta
        return np.exp(-np.dot(delta_s, np.linalg.solve(omega, delta_s)))

    def cross(self, ind_1, ind_2):
        """Generates a new individual by crossing ind_1 and ind_2"""
        b = np.zeros((self.p, 2 * self.m),
                     dtype=float)              # binary ontogenetic matrix
        y = np.zeros(2 * self.m, dtype=float)  # gene vector
        for i in range(self.m):
            alele_1 = np.random.randint(0, 2)
            alele_2 = np.random.randint(0, 2)
            y[2 * i] = ind_1['y'][2 * i + alele_1]
            y[2 * i + 1] = ind_2['y'][2 * i + alele_2]
            b[:, 2 * i] = ind_1['b'][:, 2 * i + alele_1]
            b[:, 2 * i + 1] = ind_2['b'][:, 2 * i + alele_2]
        x = np.dot(b, y)                       # additive effects vector
        z = x + np.random.normal(0, self.amb,
                                 self.p)       # phenotipic values vector
        return {'y': y, 'x': x, 'z': z, 'b': b}


class Population:
    """class for population of Individuals"""
    def __init__(self, n_e, teta, omega, indmod):
        self.indmod = indmod
        self.n_e = n_e
        self.teta = teta
        self.omega = omega
        self.pop = [indmod.generate() for k in range(n_e)]
        self.fitness = np.ones(n_e) / n_e

    def mutate(self):
        """mutates every individual of population"""
        #TODO Obviously parallel
        for k in range(self.n_e):
            self.indmod.mutate(self.pop[k])

    def update_fitness(self):
        """calculates the fitness of every individual of population"""
        #TODO Obviously parallel
        for k in range(self.n_e):
            self.fitness[k] = self.indmod.fitness(self.pop[k],
                                                  self.omega,
                                                  self.teta)
        self.fitness = self.fitness / sum(self.fitness)

    def next_generation(self):
        """creates next generation by mutating crossing with probability
        proportional do fitness"""
        self.mutate()
        self.update_fitness()
        sires = np.random.choice(self.n_e, size = self.n_e,
                p=self.fitness, replace = True)
        dames = np.random.choice(self.n_e, size = self.n_e,
                p=self.fitness, replace = True)
        new_pop = []
        #TODO Obviously parallel
        for k in range(self.n_e):
            new_pop.append(self.indmod.cross(self.pop[sires[k]],
                                             self.pop[dames[k]]))
        self.pop = new_pop

    def matrices(self):
        """Calculate covariance and correlation matrices"""
        zs = np.array([ind['z'] for ind in self.pop])
        xs = np.array([ind['x'] for ind in self.pop])
        phenotipic = np.cov(zs.transpose())
        genetic = np.cov(xs.transpose())
        outer_diagonal = phenotipic[np.diag_indices_from(phenotipic)]
        outer_diagonal = (outer_diagonal[:, np.newaxis] * outer_diagonal)
        corr_phenotipic = phenotipic / outer_diagonal
        outer_diagonal = genetic[np.diag_indices_from(genetic)]
        outer_diagonal = (outer_diagonal[:, np.newaxis] * outer_diagonal)
        corr_genetic = genetic / outer_diagonal
        return {'P': phenotipic, 'G': genetic, 'corrP': corr_phenotipic,
                'corrG': corr_genetic}
