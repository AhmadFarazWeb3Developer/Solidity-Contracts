
### **Steps involved for deployment**

#### **1. Deploy the "Factory of Factories" (SingletonFactory)***

- **What**: This is the master factory that will create all other contracts
- **Why**: It uses CREATE2 to give predictable addresses, like a construction company that always builds at the same address
- **How**: Just deploy it once - `new SingletonFactory()`

#### **2. Create the "Master Blueprint" (Safe Singleton)**

- **What**: The actual Safe contract logic that all user Safes will use
- **Why**: Only one copy needed - all user Safes will borrow this logic
- **How**:
  - Get the construction plans: `type(Safe).creationCode`
  - Choose a unique building plot: `keccak256("GnosisSafeDeployment")`
  - Have the factory build it: `singletonFactory.deploy(plans, plot)`

#### **3. Create the "Safe Maker Machine" (SafeProxyFactory)**

- **What**: A factory that mass-produces individual Safes for users
- **Why**: Makes Safe creation cheap and consistent
- **How**:
  - Get machine blueprints: `type(SafeProxyFactory).creationCode`
  - Choose machine location: `keccak256("GnosisSafeProxyFactoryDeployment")`
  - Build the machine: `singletonFactory.deploy(blueprints, location)`

#### **4. Create the "Emergency Handler" (CompatibilityFallbackHandler)**

- **What**: A helper contract that handles unexpected situations
- **Why**: Makes Safes more robust and compatible
- **How**:
  - Get helper instructions: `type(CompatibilityFallbackHandler).creationCode`
  - Choose helper station: `keccak256("GnosisSafeFallbackHandlerDeployment")`
  - Deploy the helper: `singletonFactory.deploy(instructions, station)`

#### **5. Create Individual User Safes (SafeProxy)**

- **What**: Actual Safe accounts for end users
- **Why**: Each user gets their own Safe with shared logic from the master blueprint
- **How**:
  - Tell the machine what kind of Safe to make (owners, security rules)
  - Give it a unique serial number (`saltNonce`)
  - Machine creates the Safe: `proxyFactory.createProxyWithNonce(masterBlueprint, instructions, serialNumber)`

`creationCode` is a special property in Solidity that returns the bytecode that would be deployed when creating a contract. It includes:

The contract's initialization code

The constructor logic

The contract's runtime bytecode
