# ***Semi-supervised adversarial neural networks for single-cell classification***

### by: Jacob C. Kimmel and David R. Kelley
---

## **Abstract**

**scNym**: semi-supervised, adversarial neural network that learns to transfer cell identity annotations from one experiment to another
- uses both labelled and new unlabeled datasets => rich representations of cell identity that enable effective annotation transfer
- effectively transfers annotations acroos experiments
- performance superior to existing methods
- synthesize information from multiple training and target datasets to improve performance
- high accuracy
- well-calibrated adn interpretable with saliency methods

## **Introduction**

**Problem**: manually annotating cell identities for biological insights is time consuming, somewhat subjective, and error prone
- suggestions that incorporating information from the target data during training can improve the performance of prediction models

**Proposition**: use mixed observations
- cell type classification model that uses semi-supervised and adversarial machine learning techniques to take advantage of both labeled and unlabeled single cell datasets

## **Results**

### **scNym**

Semi-supervised Learning Framework
- trains the model parameters on both labeled and unlabeled data => leverage the structure in the target dataset
- does not access ground truth labels for the target data
- ground truth labels used exclusively to evaluate model performance

