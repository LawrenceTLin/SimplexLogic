# SimplexLogic: Differentiable Logic Networks Trained on the Whole Probability Simplex

This repository contains an extended implementation of the DiffLogic code written by the authors of Petersen et. al. (2022), who developed a method to train differentiable neural networks built on logical operations instead of traditional linear transformations.

## Features
- **Logic-based neural networks** using the 16 possible binary operations (AND, OR, XOR, etc.)
- **Fully differentiable architecture** that can be trained with backpropagation
- **MNIST classification examples** demonstrating practical applications
- **Gradient behavior analysis tools** for deep networks
- **Entropy regularization** to encourage discrete logic gate selection
- **Simplex projection** to maintain valid probability distributions
- **Progressive discretization** with partial rounding and freezing
- **Annealing schedules** for entropy regularization

## Requirements

- Python 3.7+
- PyTorch 1.8+
- NumPy
- Matplotlib
- tqdm (for progress bars)
- torchvision (for MNIST examples)

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/logicnets.git
cd logicnets

# Install dependencies
pip install -r requirements.txt
```

## Logic Operations

Both implementations support all 16 possible binary logic operations:

| ID | Operator         | AB=00 | AB=01 | AB=10 | AB=11 |
|----|------------------|-------|-------|-------|-------|
| 0  | 0 (False)        | 0     | 0     | 0     | 0     |
| 1  | A AND B          | 0     | 0     | 0     | 1     |
| 2  | A AND NOT B      | 0     | 0     | 1     | 0     |
| 3  | A                | 0     | 0     | 1     | 1     |
| 4  | NOT A AND B      | 0     | 1     | 0     | 0     |
| 5  | B                | 0     | 1     | 0     | 1     |
| 6  | A XOR B          | 0     | 1     | 1     | 0     |
| 7  | A OR B           | 0     | 1     | 1     | 1     |
| 8  | NOR              | 1     | 0     | 0     | 0     |
| 9  | XNOR             | 1     | 0     | 0     | 1     |
| 10 | NOT B            | 1     | 0     | 1     | 0     |
| 11 | A OR NOT B       | 1     | 0     | 1     | 1     |
| 12 | NOT A            | 1     | 1     | 0     | 0     |
| 13 | NOT A OR B       | 1     | 1     | 0     | 1     |
| 14 | NAND             | 1     | 1     | 1     | 0     |
| 15 | 1 (True)         | 1     | 1     | 1     | 1     |

## Core Components

#### LogicLayer
The basic building block that implements differentiable logic operations:

```python
layer = LogicLayer(
    in_dim=784,             # Input dimension
    out_dim=1024,           # Output dimension
    device='cuda',          # Device to use
    initialization='dirichlet',  # Weight initialization method
    alpha=0.001             # Dirichlet concentration parameter
)
```

#### LogicGateNetwork
A network built with LogicLayers and entropy regularization:

```python
model = LogicGateNetwork(
    in_dim=784,                    # Input dimension
    hidden_dims=[800, 800, 800],   # Hidden layer dimensions
    num_classes=10,                # Number of output classes
    device='cuda',                 # Device to use
    connections='unique',          # Connection pattern
    grad_factor=1.0,               # Gradient scaling
    tau=0.1                        # Temperature for output layer
)
```

#### SimplexProjectedOptimizer
A wrapper for optimizers that projects weights onto the probability simplex:

```python
base_optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
optimizer = SimplexProjectedOptimizer(base_optimizer)
```

#### EntropyRegScheduler
Controls the strength of entropy regularization during training:

```python
entropy_scheduler = EntropyRegScheduler(
    init_value=0.01,     # Initial regularization strength
    final_value=1.0,     # Final regularization strength
    epochs=50,           # Total training epochs
    warmup=5             # Warmup epochs with minimal regularization
)
```

## Usage Examples

```python
# Create a model
model = LogicGateNetwork(
    in_dim=784,
    hidden_dims=[800, 800, 800, 800],
    num_classes=10,
    device='cuda',
    connections='unique'
)

# Mark weights for projection
model.mark_weights_for_projection()

# Create optimizer with simplex projection
base_optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
optimizer = SimplexProjectedOptimizer(base_optimizer)

# Create entropy regularization scheduler
entropy_scheduler = EntropyRegScheduler(
    init_value=0.01,
    final_value=1.0,
    epochs=50,
    warmup=5
)

# Training loop with entropy regularization
for epoch in range(num_epochs):
    # Update entropy regularization strength
    current_entropy_reg = entropy_scheduler.step(epoch)
    
    # Train with entropy regularization
    train_loss, train_acc, entropy_loss = train_epoch(
        model, optimizer, train_loader, device, 
        entropy_reg_lambda=current_entropy_reg
    )
    
    # Partially round and freeze weights periodically
    if (epoch + 1) % rounding_interval == 0:
        partial_round_and_freeze(model, entropy_threshold)
```

## Experiments and Analysis

The repository includes various experiments and analysis tools:

### Alpha Parameter Analysis for DeepDiffNet
Analyze the impact of the Dirichlet alpha parameter on gradient propagation:

```python
python alpha_search_experiment.py
```

### Initialization Method Comparison
Compare different initialization strategies:

```python
python initialization_comparison.py
```

### Entropy Regularization Experiments
Test different entropy regularization strengths:

```python
python entropy_reg_experiment.py
```

### Weight Analysis

After training, analyze the learned logic operations:

```python
gate_operations, entropy = analyze_weights(model)

print("\nMost common operations by layer:")
for layer, ops in gate_operations.items():
    sorted_ops = sorted(ops.items(), key=lambda x: x[1], reverse=True)
    
    print(f"\n{layer}:")
    for op, count in sorted_ops[:5]:
        print(f"  Operation #{op}: {count} neurons")
```

## License

[MIT License](LICENSE)

## Acknowledgments

- This work builds upon Petersen, et al. (2022). Deep differentiable logic gate networks. Advances in Neural Information Processing Systems (NeurIPS).
