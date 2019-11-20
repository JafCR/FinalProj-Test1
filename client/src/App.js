import React, { Component } from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import MyClassContract from "./contracts/ClassContract.json";
import getWeb3 from "./getWeb3";
import University from './University/University'

import "./App.css";

class App extends Component {
  state = { 
    storageValue: 0, web3: null, accounts: null, contract: null, universityId: -1,
    universities: [
      {name: 'Jaf Uni1', url: 'www.jaf1.com'},
      {name: 'Jaf Uni2', url: 'www.uni2.com'}
    ]
  }

  addUniversityHandler = async () => {
    console.log('button was clicked');    
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = SimpleStorageContract.networks[networkId];
      const instance = new web3.eth.Contract(
        SimpleStorageContract.abi,
        deployedNetwork && deployedNetwork.address,
      );
      const instance_ClassContract = new web3.eth.Contract(
        MyClassContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance, instance_ClassContract }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    await contract.methods.set(7).send({ from: accounts[0] });

    // Get the value from the contract to prove it worked.
    const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ storageValue: response });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <p>Your Truffle Box is installed and ready.</p>
        <h2>Smart Contract Example</h2>
        <p>
          If your contracts compiled and migrated successfully, below will show
          a stored value of 5 (by default).
        </p>
        <p>
          Try changing the value stored on <strong>line 40</strong> of App.js.
        </p>
        <div>The stored value is: {this.state.storageValue}</div>
        <hr/>
        <University name={this.state.universities[0].name} url={this.state.universities[0].url} />    
        <hr /> <br />
        <h1>Create University!</h1>        
        University Name: <input /> <br/>
        Description: <input /> <br/>
        Website: <input /> <br/>
        Phone Number: <input /> <br/>
        <button onClick={this.addUniversityHandler}>Add University</button>    
      </div>
    );
  }
}

export default App;
