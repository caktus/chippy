import React from "react";
import { chain, sortBy } from 'lodash';


const Project = ({name}) => (
  <div className="row">
    <div className="column column-20">
      <div className="row">
        {name}
      </div>
      <div className="row">
        <button className="button button-small button-clear">-</button>
        <button className="button button-small button-clear">+</button>
      </div>
    </div>
    <div className="column column-80">
      <div className="row">
        Chips go here
      </div>
    </div>
  </div>
);

class SprintBoard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      channel: null,
      channelError: null,
      newProjectName: "",
      sprintData: {},
    };
  }

  bindChannelListeners = channel => {
    channel.on("display", this.onDisplay);
  };

  onDisplay = resp => {
    console.log("Display data received:", resp);
    this.setState({
      sprintData: resp,
    })
  };

  componentDidMount() {
    const channel = this.props.socket.channel(`sprint:${this.props.sid}`, {});
    channel
      .join()
      .receive("ok", response => {
        console.log("Joined, received response:", response);
        this.setState({
          channel
        });
        this.bindChannelListeners(channel);
      })
      .receive("error", channelError => {
        this.setState({
          channelError
        });
      });
  }

  addProject = () => {
    this.state.channel.push('new_project', { project_name: this.state.newProjectName});
  };

  render() {
    const projects =
      chain(Object.entries(this.state.sprintData.project_allocations || {}))
      .sortBy(([k,v]) => k)
      .map(([k, v]) => [k, sortBy(Object.entries(v), ([k, v]) => k)])
      .value();

    return (
      <section className="chips">
        {
          projects.map(project => (
            <Project key={project[0]} name={project[0]} />
          ))
        }
        <div className="row">
          <div className="column column-20">
            <div className="row">
              <input
                type="text"
                placeholder="Project name"
                value={this.state.newProjectName}
                onChange={({ target: { value } }) => {
                  this.setState({ newProjectName: value });
                }}
              />
            </div>
          </div>
          <div className="column column-20">
            <div className="row">
              <button
                onClick={this.addProject}
                disabled={!this.state.newProjectName}
              >
                Add project
              </button>
            </div>
          </div>
        </div>
      </section>
    );
  }
}

export default SprintBoard;
