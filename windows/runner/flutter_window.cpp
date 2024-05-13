#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <optional>

#include "flutter/generated_plugin_registrant.h"

std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& mouseEvents = nullptr;

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

    //监听鼠标侧键的EventChannel
    const auto channelName = "pixes/mouse";
    flutter::EventChannel<> channel2(
        flutter_controller_->engine()->messenger(), channelName,
        &flutter::StandardMethodCodec::GetInstance()
    );

    auto eventHandler = std::make_unique<
        flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
    [](
        const flutter::EncodableValue* arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events){
            mouseEvents = std::move(events);
            return nullptr;
    },
    [](const flutter::EncodableValue* arguments)
        -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> {
            mouseEvents = nullptr;
            return nullptr;
    });

    channel2.SetStreamHandler(std::move(eventHandler));

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    //this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void mouse_side_button_listener(unsigned int input)
{
    if(mouseEvents != nullptr)
    {
        mouseEvents->Success(static_cast<int>(input));
    }
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
    UINT button = GET_XBUTTON_WPARAM(wparam);
    if (button == XBUTTON1 && message == 528)
    {
        mouse_side_button_listener(0);
    }
    else if (button == XBUTTON2 && message == 528)
    {
        mouse_side_button_listener(1);
    }
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
