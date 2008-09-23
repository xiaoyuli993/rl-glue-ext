function shouldQuit=runEnvironmentLoop()
    global p__rlglueEnvStruct;
    %This is all just copied in from ClientEnv in the Java codec    
    
    shouldQuit=false;
    network=p__rlglueEnvStruct.network;
    env=p__rlglueEnvStruct.theEnviroment;
    network.clearRecvBuffer();
    recvSize = network.recv(8) - 8; %// We may have received the header and part of the payload
                                    %// We need to keep track of how much of the payload was recv'd

    envState = network.getInt(0);
    dataSize = network.getInt(org.rlcommunity.rlglue.codec.network.Network.kIntSize);

    remaining = dataSize - recvSize;
    if remaining < 0
        fprintf(1,'Remaining was less than 0!\n');
    end

    amountReceived = network.recv(remaining);			

    network.flipRecvBuffer();

    %// We have already received the header, now we need to discard it.
    network.getInt();
    network.getInt();

    switch(envState)
        
    case {org.rlcommunity.rlglue.codec.network.Network.kEnvInit}
		taskSpec = env.env_init();

		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvInit);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(taskSpec)); %// This is different than taskSpec.length(). It also includes
		network.putString(taskSpec);

    case {org.rlcommunity.rlglue.codec.network.Network.kEnvStart}
		obs = env.env_start();

		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvStart);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(obs));
		network.putObservation(obs);

    case {org.rlcommunity.rlglue.codec.network.Network.kEnvStep}
		action = network.getAction();
		rewardObservation = env.env_step(action);	
		
		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvStep);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(rewardObservation));

		network.putRewardObservation(rewardObservation);

    case {org.rlcommunity.rlglue.codec.network.Network.kEnvCleanup}
		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvCleanup);
		network.putInt(0);

    case {org.rlcommunity.rlglue.codec.network.Network.kEnvSetState}
		key = network.getStateKey();
		env.env_set_state(key);

		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvSetState);
		network.putInt(0);


    case {org.rlcommunity.rlglue.codec.network.Network.kEnvSetRandomSeed}
		key = network.getRandomSeedKey();
		env.env_set_random_seed(key);
			
		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvSetRandomSeed);
		network.putInt(0);

   case {org.rlcommunity.rlglue.codec.network.Network.kEnvGetState}
		key = env.env_get_state();
		
		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvGetState);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(key));
		network.putStateKey(key);

   case {org.rlcommunity.rlglue.codec.network.Network.kEnvGetRandomSeed}
		key = env.env_get_random_seed();
		
		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvGetRandomSeed);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(key));
		network.putRandomSeedKey(key);

    case {org.rlcommunity.rlglue.codec.network.Network.kEnvMessage}
		message = network.getString();
		reply = env.env_message(message);

		network.clearSendBuffer();
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.kEnvMessage);
		network.putInt(org.rlcommunity.rlglue.codec.network.Network.sizeOf(reply));
		network.putString(reply);

    case {org.rlcommunity.rlglue.codec.network.Network.kRLTerm}
        disconnectEnvironment();
        shouldQuit=true;
        return;
   otherwise
        fprintf(2,'Unknown state in runEnvironmentLoop %d\n',envState);
        exit(1);
    end
    
    network.flipSendBuffer();
    network.send();
end