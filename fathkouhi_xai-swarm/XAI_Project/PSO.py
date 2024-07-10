import numpy as np

class PSO:
    def __init__(self, no_bat, dimension, no_generation, lb, ub, model_predict, sample):
        self.loss = 0
        self.sample = sample
        self.model_predict = model_predict
        self.no_bat = no_bat
        self.fitness = [0.0] * self.no_bat
        self.p_fitness = [0.0] * self.no_bat
        self.best_index = 0
        self.dimension = dimension
        self.best_history = []

        self.v = [[0.0 for i in range(self.dimension)] for j in range(self.no_bat)]

        self.particle = [[0.0 for i in range(self.dimension)] for j in range(self.no_bat)]
        self.p_best_particle = [[0.0 for i in range(self.dimension)] for j in range(self.no_bat)]

        self.upperbound = [[0.0 for i in range(self.dimension)] for j in range(self.no_bat)]
        self.lowerbound = [[0.0 for i in range(self.dimension)] for j in range(self.no_bat)]

        self.fitness_minimum = 0.0
        self.best = [0.0] * self.dimension
        self.no_generation = no_generation
        self.lb = lb
        self.ub = ub
        self.c1 = 2
        self.c2 = 2
        self.w = 1
        self.v_min = -2
        self.v_max = 2
        self.itr = 0
        self.p_no = 0

    def best_particle(self):
        i = 0
        j = 0

        for i in range(self.no_bat):
            if self.fitness[i] < self.fitness[j]:
                j = i

        for i in range(self.dimension):
            self.best[i] = self.particle[j][i]

        self.fitness_minimum = self.fitness[j]
        self.best_index = j

    def process_init(self):
        for i in range(self.no_bat):
            for j in range(self.dimension):
                self.lowerbound[i][j] = self.lb
                self.upperbound[i][j] = self.ub

        for i in range(self.no_bat):
            print('initialization: ',i)
            for j in range(self.dimension):
                random = np.random.uniform(0, 1)
                self.v[i][j] = self.v_min + (self.v_max - self.v_min) * random
                self.particle[i][j] = self.lowerbound[i][j] + (self.upperbound[i][j] - self.lowerbound[i][j]) * random
            cost_eval = self.Cost_eval(self.particle[i])
            self.fitness[i] = cost_eval

        self.p_best_particle = np.copy(self.particle)
        self.p_fitness = np.copy(self.fitness)
        self.best_particle()


    def normalization_particle(self, X):
        if X > self.ub:
            X = self.ub
        if X < self.lb:
            X = self.lb
        return X

    def normalization_velocity(self, v):
        if v > self.v_max:
            v = self.v_max
        if v < self.v_min:
            v = self.v_min
        return v

    def process(self):
        self.process_init()
        for n in range(self.itr, self.no_generation):
            print('iteration: ', n)
            for i in range(self.p_no, self.no_bat):
                for j in range(self.dimension):
                    self.v[i][j] = self.w * self.v[i][j] + (self.best[j] - self.particle[i][j]) * self.c2 * np.random.rand(1) + \
                                   (self.p_best_particle[i][j] - self.particle[i][j]) * self.c1 * np.random.rand(1)

                    self.particle[i][j] = np.float(self.particle[i][j] + self.v[i][j])
                    self.v[i][j] = self.normalization_velocity(self.v[i][j])
                    self.particle[i][j] = self.normalization_particle(self.particle[i][j])

                    self.fitness[i] = self.Cost_eval(self.particle[i])

                    if self.fitness[i] < self.p_fitness[i]:
                        for j in range(self.dimension):
                            self.p_best_particle[i][j] = self.particle[i][j]
                        self.p_fitness[i] = self.fitness[i]

                    if self.fitness[i] < self.fitness_minimum:
                        self.fitness_minimum = self.fitness[i]
                        self.best_index = i
                        for j in range(self.dimension):
                            self.best[j] = self.particle[i][j]

            self.best_history.append(self.fitness_minimum)
            # print('iter: ' + str(n) + ' minimum : ', self.fitness_minimum, 'predict sample: ', np.dot(self.best, self.sample.T))
            self.p_no = 0

        return self.best

    def Cost_eval(self, solution):
        self.loss = -1 * np.sum(solution * np.sin(np.sqrt(np.abs(solution))))
        # self.loss = (self.model_predict - np.dot(solution, self.sample.T)) ** 2
        print('loss is: ', self.loss)
        return self.loss