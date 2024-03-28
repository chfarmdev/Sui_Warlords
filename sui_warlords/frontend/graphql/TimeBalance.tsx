/*

// Will delete later, just leaving in case I have issues with react-query direct graphql later. And need Axios for something.

import axios from "axios";

import { BalanceType } from "./queries";

const graphServer = process.env.GRAPHQL_SERVER

const getBalances = async (address: string, type: string): Promise<BalanceType> => {
  
  const query = `
  query GetBalance($address: String!, $type: String!) {
    address(address: $address) {
      balance(type: $type) {
        coinObjectCount
        totalBalance
      }      
    }
  }
`;

const variables = {
  address: address,
  type: type,
};  

  const options = {
    method: 'POST',
    url: 'https://sui-testnet.mystenlabs.com/graphql',
    headers: {
      'content-type': 'application/json',
    },
    data: {
      query,
      variables,
    }
    
  };

  try {
    const response = await axios.request<BalanceType>(options);
    const res = response.data;
    console.log(res);
    
    return res;
  } catch (error) {
    console.error(error);
    throw error;
  }
};

*/