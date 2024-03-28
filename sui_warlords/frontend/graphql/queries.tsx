import { gql } from 'graphql-request'

export interface BalanceType {
  address: Address;
};

interface Address {    
  balance: Balance,
};

interface Balance {    
  coinObjectCount: number,
  totalBalance: number,
};

export const allBalances = gql `
  query GetBalance($address: String!, $type: String!) {
    address(address: $address) {
      balance(type: $type) {
        coinObjectCount
        totalBalance
      }      
    }
  }
`;
