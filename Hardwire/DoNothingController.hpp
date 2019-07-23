// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// This controller does absolutely nothing.
// It is useful for hardwiring conductances, though.

#ifndef DONOTHINGCONTROLLER
#define DONOTHINGCONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class DoNothingController: public mechanism {

protected:
    // flag used to switch between
    // controlling channels and synapses
    // meaning:
    // 0 --- unset, will throw an error
    // 1 --- channels
    // 2 --- synapses
    int control_type = 0;
public:
    // timescales
    double tau_m = std::numeric_limits<double>::infinity();
    double tau_g = 5e3;

    // mRNA concentration
    double m = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    DoNothingController(double tau_m_, double tau_g_, double m_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        m = m_;


        // if (tau_m<=0) {mexErrMsgTxt("[IntegralController] tau_m must be > 0. Perhaps you meant to set it to Inf?\n");}
        if (tau_g<=0) {mexErrMsgTxt("[DoNothingController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
    }


    void integrate(void);

    void checkSolvers(int);

    void connect(conductance *);
    void connect(synapse*);
    void connect(compartment*);

    int getFullStateSize(void);
    int getFullState(double * cont_state, int idx);
    double getState(int);

};


double DoNothingController::getState(int idx)
{
    if (idx == 1) {return m;}
    else if (idx == 2) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int DoNothingController::getFullStateSize(){return 2; }


int DoNothingController::getFullState(double *cont_state, int idx)
{
    // give it the current mRNA level
    cont_state[idx] = m;

    idx++;

    // and also output the current gbar of the thing
    // being controller
    if (channel)
    {
      cont_state[idx] = channel->gbar;
    }
    else if (syn)
    {
        cont_state[idx] = syn->gmax;
    }
    idx++;
    return idx;
}


void DoNothingController::connect(conductance * channel_)
{

    // connect to a channel
    channel = channel_;


    // make sure the compartment that we are in knows about us
    (channel->container)->addMechanism(this);



    controlling_class = (channel_->getClass()).c_str();

    // attempt to read the area of the container that this
    // controller should be in.
    container_A  = (channel->container)->A;

    control_type = 1;


}

void DoNothingController::connect(compartment* comp_)
{
    mexErrMsgTxt("[DoNothingController] This mechanism cannot connect to a compartment object");
}

void DoNothingController::connect(synapse* syn_)
{

    // connect to a synpase
    syn = syn_;


    // make sure the compartment that we are in knows about us
    (syn->post_syn)->addMechanism(this);


    // attempt to read the area of the container that this
    // controller should be in.
    container_A  = (syn->post_syn)->A;

    control_type = 2;

}


void DoNothingController::integrate(void)
{


    switch (control_type)
    {
        case 0:
            mexErrMsgTxt("[DoNothingController] misconfigured controller. Make sure this object is contained by a conductance or synapse object");
            break;


        case 1:

            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled
            // and do nothing
            if (isnan((channel->container)->Ca_target_1)) {return;}

            break;

            }
        case 2:
            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled
            // and do nothing

            if (isnan((syn->post_syn)->Ca_target_1)) {return;}

            break;

            }

        default:
            mexErrMsgTxt("[DoNothingController] misconfigured controller");
            break;

    }


}



void DoNothingController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[DoNothingController] unsupported solver order\n");
    }
}




#endif
