import React from "react";
import { chain, has, keys, sortBy, times } from "lodash";
import colorHash from "color-hash";
import { getUserName } from "../user";

const hasher = new colorHash();

const Project = ({ name, alloc, colors, addChip, removeChip }) => (
  <div className="row">
    <div className="column column-20">
      <div className="row">{name}</div>
      <div className="row">
        <button
          className="button button-small button-clear"
          onClick={removeChip}
        >
          -
        </button>
        <button className="button button-small button-clear" onClick={addChip}>
          +
        </button>
      </div>
    </div>
    <div className="column column-80">
      {alloc.map(([name, chips]) => (
        <div className="row row-chips">
          {times(chips, () => (
            <span
              className="chip"
              style={{
                backgroundColor: colors[name] || "steelblue"
              }}
            />
          ))}
        </div>
      ))}
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
      colors: {}
    };
  }

  bindChannelListeners = channel => {
    channel.on("display", this.onDisplay);
  };

  onDisplay = resp => {
    console.log("Display data received:", resp);
    this.setState((state, props) => {
      const { project_allocations } = resp;
      const colors = chain(project_allocations)
        .values()
        .map(keys)
        .flatten()
        .uniq()
        .reduce(
          (acc, name) =>
            Object.assign(
              {},
              acc,
              has(acc, name) ? {} : { [name]: hasher.hex(name) }
            ),
          Object.assign({}, state.colors)
        )
        .value();
      console.log(colors);
      return {
        sprintData: resp,
        colors
      };
    });
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
    this.state.channel.push("new_project", {
      project_name: this.state.newProjectName
    });

    this.setState({
      newProjectName: ""
    });
  };

  addChipTo = projectName => () => {
    this.state.channel.push("add_chip", {
      project_name: projectName,
      person_name: getUserName()
    });
  };

  removeChipFrom = projectName => () => {
    this.state.channel.push("remove_chip", {
      project_name: projectName,
      person_name: getUserName()
    });
  };

  render() {
    const projects = chain(
      Object.entries(this.state.sprintData.project_allocations || {})
    )
      .sortBy(([k, _]) => k)
      .map(([k, v]) => [k, sortBy(Object.entries(v), ([k, _]) => k)])
      .value();

    return (
      <section className="chips">
        {projects.map(([name, alloc]) => (
          <Project
            key={name}
            name={name}
            alloc={alloc}
            colors={this.state.colors}
            addChip={this.addChipTo(name)}
            removeChip={this.removeChipFrom(name)}
          />
        ))}
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
                onKeyPress={({ key }) => {
                  if (key === "Enter") {
                    this.addProject();
                  }
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
