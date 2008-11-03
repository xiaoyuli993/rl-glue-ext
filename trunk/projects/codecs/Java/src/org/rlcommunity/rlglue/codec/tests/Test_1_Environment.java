/*
 * Copyright 2008 Brian Tanner
 * http://rl-glue-ext.ext.googlecode.com/
 * brian@tannerpages.com
 * http://brian.tannerpages.com
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.rlcommunity.rlglue.codec.tests;

import org.rlcommunity.rlglue.codec.EnvironmentInterface;
import org.rlcommunity.rlglue.codec.util.EnvironmentLoader;
import org.rlcommunity.rlglue.codec.types.Action;
import org.rlcommunity.rlglue.codec.types.Observation;
import org.rlcommunity.rlglue.codec.types.Random_seed_key;
import org.rlcommunity.rlglue.codec.types.Reward_observation_terminal;
import org.rlcommunity.rlglue.codec.types.State_key;

/**
 *
 * @author Brian Tanner
 */
public class Test_1_Environment implements EnvironmentInterface {

    int stepCount = 0;
    Observation o =new Observation();
    
    public Test_1_Environment() {
    }

    
    public String env_message(String inMessage) {
        int timesToPrint = stepCount % 3;
        StringBuffer b = new StringBuffer();

        b.append(inMessage);
        b.append("|");
        for (int i = 0; i < timesToPrint; i++) {
            b.append(stepCount);
            b.append(".");
        }
        b.append("|");
        b.append(inMessage);
        return b.toString();
    }

    public static void main(String[] args){
        EnvironmentLoader L=new EnvironmentLoader(new Test_1_Environment());
        L.run();
    }

    public String env_init() {
	return "sample task spec";    }

    public Observation env_start() {
        stepCount=0;
        TestUtility.clean_abstract_type(o);
        TestUtility.set_k_ints_in_abstract_type(o, 1);
        TestUtility.set_k_doubles_in_abstract_type(o, 2);
        TestUtility.set_k_chars_in_abstract_type(o, 3);
        return o;   
    }

    public Reward_observation_terminal env_step(Action action) {
        TestUtility.clean_abstract_type(o);
        TestUtility.set_k_ints_in_abstract_type(o, 1);
        o.intArray[0]=stepCount;
        
      	stepCount++;
                
        int terminal=0;
        if(stepCount==5)terminal=1;
        Reward_observation_terminal ro=new Reward_observation_terminal(1.0d, o, terminal);
        return ro;
    }

    public void env_cleanup() {
    }

    public void env_load_state(State_key key) {
    }

    public void env_load_random_seed(Random_seed_key key) {
    }

    public State_key env_save_state() {
        return new State_key();
    }

    public Random_seed_key env_save_random_seed() {
        return new Random_seed_key();
    }

}