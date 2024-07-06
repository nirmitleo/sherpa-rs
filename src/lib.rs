pub mod language_id;
pub mod speaker_id;
pub mod vad;

#[cfg(feature = "tts")]
pub mod tts;

pub fn get_default_provider() -> String {
    if cfg!(target_os = "macos") {
        "coreml"
    } else {
        "cpu"
    }
    .into()
}
