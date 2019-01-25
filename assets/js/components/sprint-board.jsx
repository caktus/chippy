import React from "react";

class SprintBoard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      channel: null,
      channelError: null
    };
  }

  bindChannelListeners = (channel) => {
    channel.on('by_users', this.onByUsers);
  };

  onByUsers = (resp) => {
    console.log("By users received:", resp);
  }

  componentDidMount() {
    const channel = this.props.socket.channel(`sprint:${this.props.sid}`, {});
    channel
      .join()
      .receive("ok", response => {
        console.log("Joined, received response:", response)
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

  render() {
    return <div />;
  }
}

export default SprintBoard;
