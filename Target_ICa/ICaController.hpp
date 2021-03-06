// _  _ ____ _    ____ ___ _
//  \/  |  | |    |  |  |  |
// _/\_ |__| |___ |__|  |  |___
//
// Integral controller using ICa as a sensor

#ifndef ICACONTROLLER
#define ICACONTROLLER
#include "mechanism.hpp"
#include <limits>

//inherit controller class spec
class ICaController: public mechanism {

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
    double tau_ICa = 0;

    double iCa_target = std::numeric_limits<double>::quiet_NaN();

    double smooth_ICa = 0;

    //mRNA concentration
    double m = 0;

    // area of the container this is in
    double container_A;

    // specify parameters + initial conditions for
    // mechanism that controls a conductance
    ICaController(double tau_m_, double tau_g_, double m_, double tau_ICa_, double iCa_target_, double smooth_ICa_)
    {

        tau_m = tau_m_;
        tau_g = tau_g_;
        tau_ICa = tau_ICa_;

        m = m_;

        iCa_target = iCa_target_;
        smooth_ICa = smooth_ICa_;

        if (tau_g<=0) {mexErrMsgTxt("[ICaController] tau_g must be > 0. Perhaps you meant to set it to Inf?\n");}
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


double ICaController::getState(int idx)
{
    if (idx == 1) {return m;}
    else if (idx == 2) {return channel->gbar;}
    else {return std::numeric_limits<double>::quiet_NaN();}

}


int ICaController::getFullStateSize(){return 2; }


int ICaController::getFullState(double *cont_state, int idx)
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
        cont_state[idx] = syn->gmax; //ignore
    }
    idx++;
    return idx;
}


void ICaController::connect(conductance * channel_)
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

void ICaController::connect(compartment* comp_)
{
    mexErrMsgTxt("[ICaController] This mechanism cannot connect to a compartment object");
}

void ICaController::connect(synapse* syn_)
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


void ICaController::integrate(void)
{


    switch (control_type)
    {
        case 0:
            mexErrMsgTxt("[ICaController] misconfigured controller. Make sure this object is contained by a conductance or synapse object");
            break;


        case 1:

            {
            // if the target is NaN, we will interpret this
            // as the controller being disabled
            // and do nothing
            if (isnan(iCa_target)) {return;}

            smooth_ICa += (dt/tau_ICa)*((channel->container)->i_Ca_prev - smooth_ICa); //integrate smooth_ICa using filtering

            double ICa_error = -(iCa_target - smooth_ICa); //calculate error

            // integrate mRNA
            m += (dt/tau_m)*(ICa_error);

            // mRNA levels below zero don't make any sense
            if (m < 0) {m = 0;}

            // copy the protein levels from this channel
            double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

            // make sure it doesn't go below zero
            if (channel->gbar_next + gdot < 0) {
                channel->gbar_next = 0;
            } else {
                channel->gbar_next += gdot/container_A;
            }

            break;

            }
        case 2:
            {
              // if the target is NaN, we will interpret this
              // as the controller being disabled
              // and do nothing
              if (isnan(iCa_target)) {return;}

              smooth_ICa += (dt/tau_ICa)*((channel->container)->i_Ca_prev - smooth_ICa);

              double ICa_error = (iCa_target - smooth_ICa);

              // integrate mRNA
              m += (dt/tau_m)*(ICa_error);

              // mRNA levels below zero don't make any sense
              if (m < 0) {m = 0;}

              // copy the protein levels from this channel
              double gdot = ((dt/tau_g)*(m - channel->gbar*container_A));

              // make sure it doesn't go below zero
              if (channel->gbar_next + gdot < 0) {
                  channel->gbar_next = 0;
              } else {
                  channel->gbar_next += gdot/container_A;
              }

              break;
            }
          default:
              mexErrMsgTxt("[ICaController] misconfigured controller");
              break;

      }


}



void ICaController::checkSolvers(int k) {
    if (k == 0){
        return;
    } else {
        mexErrMsgTxt("[ICaController] unsupported solver order\n");
    }
}




#endif
