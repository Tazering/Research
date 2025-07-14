import matplotlib.pyplot as plt
import numpy as np

# Define two Gaussian distributions
x = np.linspace(-5, 10, 1000)
mu1, sigma1 = 0, 1  # First Gaussian: mean=0, std=1
mu2, sigma2 = 3, 1  # Second Gaussian: mean=3, std=1

# Probability density functions
pdf1 = (1/(sigma1 * np.sqrt(2 * np.pi))) * np.exp(-0.5 * ((x - mu1)/sigma1)**2)
pdf2 = (1/(sigma2 * np.sqrt(2 * np.pi))) * np.exp(-0.5 * ((x - mu2)/sigma2)**2)

# Create the plot
plt.figure(figsize=(10, 6))
plt.plot(x, pdf1, 'b-', label='Distribution μ (mean=0)')
plt.plot(x, pdf2, 'r-', label='Distribution ν (mean=3)')
plt.fill_between(x, pdf1, alpha=0.2, color='blue')
plt.fill_between(x, pdf2, alpha=0.2, color='red')

# Add arrows to suggest mass transport
plt.arrow(0, 0.4, 3, 0, color='black', length_includes_head=True, head_width=0.02, head_length=0.5)
plt.text(1.5, 0.42, 'Mass transport', ha='center', fontsize=12)

# Plot settings
plt.title('Illustration of Wasserstein Distance\nMoving Mass from μ to ν', fontsize=14)
plt.xlabel('x', fontsize=12)
plt.ylabel('Density', fontsize=12)
plt.grid(True)
plt.legend()

# Save the plot
plt.savefig('./wasserstein_illustration.png')