import Foundation

/// Web fonts bundled in `Shared/Resources/fonts/` and loaded into the preview via `@font-face`.
///
/// System families (San Francisco, New York, SF Mono) need no declarations; bundled families return
/// one `@font-face` rule per file. `PreviewCSS.css` prepends the result to the stylesheet so every host
/// (Mac preview, iOS preview, QuickLook, PDF export/print) embeds the same declarations.
public enum PreviewFonts {
    /// `previewFontFamily` user-default value for Libre Baskerville (SIL OFL 1.1).
    public static let libreBaskerville = "libreBaskerville"

    /// CSS `font-family` stack for the body and headings of the given family.
    public static func fontStack(for fontFamily: String) -> String {
        switch fontFamily {
        case libreBaskerville:
            return "\"Libre Baskerville\", Baskerville, \"Iowan Old Style\", Georgia, serif"
        default:
            return ""
        }
    }

    /// `@font-face` declarations for the given family, or an empty string for system families.
    /// `bundle` is where the `fonts` folder lives; every app target bundles it into `Bundle.main`.
    public static func fontFaceCSS(for fontFamily: String, bundle: Bundle = .main) -> String {
        switch fontFamily {
        case libreBaskerville:
            let roman = fontSource(named: "LibreBaskerville-VariableFont_wght.ttf", bundle: bundle)
            let italic = fontSource(named: "LibreBaskerville-Italic-VariableFont_wght.ttf", bundle: bundle)
            return """
            @font-face {
                font-family: "Libre Baskerville";
                src: url("\(roman)") format("truetype");
                font-weight: 400 700;
                font-style: normal;
                font-display: block;
            }
            @font-face {
                font-family: "Libre Baskerville";
                src: url("\(italic)") format("truetype");
                font-weight: 400 700;
                font-style: italic;
                font-display: block;
            }
            """
        default:
            return ""
        }
    }

    /// `src` value for a bundled font: the absolute `file:` URL when `bundle` has it, otherwise a
    /// path relative to the document base URL (the KaTeX pattern) so hosts without the fonts folder,
    /// such as the unit-test runner, still emit well-formed CSS. Absolute URLs keep the preview
    /// independent of each host's `baseURL` (see the external-drive rendering fix in #410).
    static func fontSource(named fileName: String, bundle: Bundle = .main) -> String {
        let baseName = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        if let url = bundle.url(forResource: baseName, withExtension: ext, subdirectory: "fonts") {
            return url.absoluteString
        }
        return "fonts/\(fileName)"
    }
}
