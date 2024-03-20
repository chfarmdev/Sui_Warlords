'use client';

import { createNetworkConfig, SuiClientProvider, WalletProvider } from '@mysten/dapp-kit';
import { getFullnodeUrl } from '@mysten/sui.js/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import '@mysten/dapp-kit/dist/index.css';


// Config options for the networks you want to connect to
const { networkConfig, useNetworkVariable } = createNetworkConfig({
	testnet: {
		url: getFullnodeUrl('testnet'),
		variables: {
			myMovePackageId: '0x1c28f08ae2755860f85d287d178f41b90109e7e24dbbc50b7142ad7a5d318c12',
		}
	},
	mainnet: {
		url: getFullnodeUrl('mainnet'),
		variables: {
			myMovePackageId: '0x456',
		}
	},
});
 
const queryClient = new QueryClient();
 
export function SuiProviders({ children }: any) {
  return (
    <QueryClientProvider client={queryClient}>
      <SuiClientProvider networks={networkConfig} defaultNetwork="testnet">
        <WalletProvider>
            {children}
        </WalletProvider>
      </SuiClientProvider>
    </QueryClientProvider>
  );
}

export default SuiProviders;